#!/bin/sh -

minion_id="${1}"
repo_url="${2}"
salt_root="/srv/salt"
ssh_wrapper="${salt_root}/ssh_with_deploy_key.sh"
deploy_key="${salt_root}/deploy_key.id_rsa"
deploy_script="${salt_root}/deploy.sh"
active_code="${salt_root}/current"


# Create the salt root directory if it doesn't already exist
mkdir -p "${salt_root}"


# Create an ssh wrapper for git that injects the deploy key
cat <<-SHELL > "${ssh_wrapper}"
#!/bin/sh -e

exec /usr/bin/ssh \
  -o PasswordAuthentication=no \
  -o StrictHostKeyChecking=no \
  -o IdentityFile="${deploy_key}" \
  "\$@"
SHELL
chmod +x "${ssh_wrapper}"


# Prepare the deploy key
cp "/tmp/terraform.git_deploy_key.id_rsa" "${deploy_key}"
chown nobody:root "${deploy_key}"
chmod 0660 "${deploy_key}"


# Create the deploy script
cat <<-SHELL > "${deploy_script}"
#!/bin/sh

umask 0002

repo_url="${repo_url}"
ssh_wrapper="${ssh_wrapper}"
time_stamp=\$(date +%Y%m%d%H%M%S)
releases_path="/srv/salt/releases"
release_path="\${releases_path}/\${time_stamp}"
revisions_path="/srv/salt/revisions"

# clone
if [ ! -d "/srv/salt/repo" ]; then
  echo "Cloning repo"
  GIT_SSH="\${ssh_wrapper}" git clone --mirror "\${repo_url}" /srv/salt/repo
fi

# update
echo "Updating repo"
cd /srv/salt/repo
GIT_SSH="\${ssh_wrapper}" git remote update --prune

# release
echo "Creating release in \${release_path}"
mkdir -p "\${revisions_path}"
mkdir -p "\${releases_path}"

branch=\${1:-master}
revision=\$(git rev-list --max-count=1 \${branch})
revision_path="\${revisions_path}/\${revision}"

ln -s "\${revision_path}" "\${release_path}"

if [ ! -d "\${revision_path}" ]; then
  mkdir \${revision_path}
  git archive \${branch} | tar -x -C "\${revision_path}"
fi

# move current link to newest release
echo "Activating release in \${release_path}"
ln -s /srv/salt/releases/\${time_stamp} /srv/salt/releases/current
mv /srv/salt/releases/current /srv/salt

# prune old releases
echo "Cleaning up old releases"
(cd /srv/salt/releases && ls -t1 . | tail -n +2 | xargs rm -rf)

# prune old revisions
echo "Cleaning up old revisions"
for revision in \$(find "\${revisions_path}" -mindepth 1 -maxdepth 1 -type d); do
  references=\$(find -L "\${releases_path}" -mindepth 1 -maxdepth 1 -samefile "\${revision}")
  if [ -z "\${references}" ]; then
    echo "  Removing revision at \${revision}"
    rm -rf "\${revision}"
  fi
done

exit 0
SHELL
chmod 0755 "${deploy_script}"


# Deploy the salt code
sh "${deploy_script}"


# Finish configuring with salt-call
cd "${active_code}"
sudo salt-call --id="${minion_id}" state.highstate
