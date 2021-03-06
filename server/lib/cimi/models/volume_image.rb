# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

class CIMI::Model::VolumeImage < CIMI::Model::Base

  acts_as_root_entity

  href :image_location
  text :image_data
  text :bootable
  array :operations do
    scalar :rel, :href
  end

  def self.find(id, context)
    creds = context.credentials
    if id == :all
      snapshots = context.driver.storage_snapshots(creds)
      snapshots.collect{ |snapshot| from_storage_snapshot(snapshot, context) }
    else
      snapshot = context.driver.storage_snapshots(creds, id => :id).first
      raise CIMI::Model::NotFound unless snapshot
      from_storage_snapshot(snapshot, context)
    end
  end

  def self.all(context); find(:all, context); end

  def self.create(request_body, context)
    type = context.grab_content_type(context.request.content_type, request_body)
    input = (type == :xml)? XmlSimple.xml_in(request_body.read, {"ForceArray"=>false,"NormaliseSpace"=>2}) : JSON.parse(request_body.read)
    params = {:volume_id => context.href_id(input["imageLocation"]["href"], :volumes), :name=>input["name"], :description=>input["description"]}
    vol_image = context.driver.create_storage_snapshot(context.credentials, params)
    from_storage_snapshot(vol_image, context)
  end

  def self.delete!(vol_image_id, context)
    context.driver.destroy_storage_snapshot(context.credentials, {:id=>vol_image_id})
  end

  private

  def self.from_storage_snapshot(snapshot, context)
    self.new( {
               :name => snapshot.name || snapshot.id,
               :description => snapshot.description || snapshot.id,
               :created => snapshot.created.nil? ? nil : Time.parse(snapshot.created).xmlschema,
               :id => context.volume_image_url(snapshot.id),
               :image_location => {:href=>context.volume_url(snapshot.storage_volume_id)},
               :bootable => "false"  #FIXME
            } )
  end

end
