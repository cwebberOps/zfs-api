#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'base64'
require 'json'

perms = 'unauthorized'

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
  data = {"fs" => fs, "quota" => 40}
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
      # Do stuff
      status 200
      body(req.to_json)
    end
  else
    error 401
  end
end

# Delete a zfs filesystem
delete '/zfs/:fs' do
  if perms == 'rw'
    fs = Base64.decode64(params[:fs])
    status 200
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

