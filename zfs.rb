#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'base64'
require 'json'

ZFSGET = '/usr/sbin/zfs get -Hp'

perms = 'unauthorized'

permitted_zpools = [
 'pool0',
]

permitted_options = [
  'quota',
]

rw_keys = [
  'uamV3xkCVr22yzTqphrtZUGc',
  'ZxWekUAvU3NVHfuyHmLWcqGk',
  '6e6eHSxreRmMSxm3FUjJTAWh',
  'KxcPDuyXpvZMdd6nLfLmuhWh',
  'xst6LuxnCM4x3CQS5dRwD4zM',
]

ro_keys = [
  'pquYaWARkCYKWHtykBsFuQVN',
  'msTJ7Xz76AwzAwkCB8Kd6UFu',
  '5ztJJAAyQxkweJtrNupNbN6U',
  'UhebKcAjEQV5SQSA9jZS9R7x',
  'f4ZpeVEQnFwUpr9ZXtBmL2p4',
]

before do
  key = request.env['HTTP_X_ZFS_API_KEY']
  puts "Key: #{key}"

  if ro_keys.include?(key)
    perms = 'ro'
  end

  if rw_keys.include?(key)
    perms = 'rw'
  end

  puts "Permissions: #{perms}"

  unless ['rw', 'ro'].include?(perms)
    error 401
  end

end

# Enumerate the filesystem
#
# Returns:
#   zfs properties
get '/zfs/:fs' do

  fs = Base64.decode64(params[:fs])

  # Sanitization code goes here...

  zpool = fs.split('/')[0]

  # Verify that we can operate on this pool at all
  unless permitted_zpools.include?(zpool)
    error 403
  end

  raw_data = `#{ZFSGET} all #{fs}`
  unless $?.to_i == 0
    error 404
  end

  data = {}
  raw_data.each_line do |line|
    property = line.split()
    data[property[1]] = {"value" => property[2], "source" => property[3]}
  end

  puts "Filesystem: #{fs}"
  status 200
  body(data.to_json)
end

# Create a zfs filesystem
#
# Takes a json blob with the name of the zfs filesystem
# and the various options
put '/zfs' do
  if perms == 'rw'
    req = JSON.parse(request.body.string)
    if req.nil?
      status 400
    else

      fs = req['fs']

      # verify that we can work on this zpool
      zpool = fs.split('/')[0]
      unless permitted_zpools.include?(zpool)
        error 403
      end

      # Handle the options
      options = ''
      if req['options']
        req['options'].each_key do |opt|
          unless permitted_options.include?(opt)
            error 403
          end
          options << "-o #{opt}=#{req['options'][opt]}"
        end
      end

      `/usr/sbin/zfs create #{options} #{fs}`
      if $? == 0
        status 200
        body(req.to_json)
      else
        error 500
      end
    end
  else
    error 401
  end
end

# Delete a zfs filesystem
delete '/zfs/:fs' do
  if perms == 'rw'
    fs = Base64.decode64(params[:fs])
    # verify that we can work on this zpool
    zpool = fs.split('/')[0]
    unless permitted_zpools.include?(zpool)
      error 403
    end

    `/usr/sbin/zfs destroy #{fs}`
    if $?.to_i == 0
      status 200
    else
      status 500
    end
  else
    error 401
  end
end

# Change the filesystem
#
# Returns:
#   zfs properties
post '/zfs/:fs' do
  if perms == 'rw'
    req = JSON.parse(request.body.string)
    if req.nil?
      status 400
    else
      # Do stuff
      status 200
      body(req.to_json)
    end
  else
    error 401
  end
end

