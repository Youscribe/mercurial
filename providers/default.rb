def windows?
  node[:platform] == "windows"
end

action :sync do
  execute "#{new_resource} sync repository #{new_resource.path}" do
    not_if "hg identify #{new_resource.path}"
    if windows?
      command "hg clone #{new_resource.repository} #{new_resource.path}"
    else
      command "hg clone -e 'ssh -i #{new_resource.key} -o StrictHostKeyChecking=no' #{new_resource.repository} #{new_resource.path}"
    end
  end

  execute "#{new_resource} pull changes #{new_resource.path}" do
    command "cd #{new_resource.path}"
    if windows?
      command "hg pull #{new_resource.repository}"
    else
      command "hg pull -e 'ssh -i #{new_resource.key} -o StrictHostKeyChecking=no' #{new_resource.repository}"
    end
  end

  execute "#{new_resource} update #{new_resource.path}[#{new_resource.revision.to_s}]" do
    command "cd #{new_resource.path}"
    command "hg update -r #{new_resource.revision}"
  end

  # TODO: Add permissions support in windows
  unless windows?
    execute "#{new_resource} sync update owner #{new_resource.path}" do
      command "chown -R #{new_resource.owner}:#{new_resource.group} #{new_resource.path}"
    end
    execute "#{new_resource} sync update permissions #{new_resource.path}" do
      command "chmod -R #{new_resource.mode} #{new_resource.path}"
    end
  end
end

action :clone do
  execute "#{new_resource} clone repository #{new_resource.path}" do
    not_if "hg identify #{new_resource.path}"
    if windows?
      command "hg clone #{new_resource.repository} #{new_resource.path}"
    else
      command "hg clone -e 'ssh -i #{new_resource.key} -o StrictHostKeyChecking=no' #{new_resource.repository} #{new_resource.path}"
    end
  end

  if new_resource.revision
      command "cd #{new_resource.path}"
      command "hg update -r #{new_resource.revision}"
  end

  # TODO: Add permissions support in windows
  unless windows?
    execute "#{new_resource} update owner #{new_resource.path}" do
      command "chown -R #{new_resource.owner}:#{new_resource.group} #{new_resource.path}"
    end
    execute "#{new_resource} update permissions #{new_resource.path}" do
      command "chmod -R #{new_resource.mode} #{new_resource.path}"
    end
  end
end
