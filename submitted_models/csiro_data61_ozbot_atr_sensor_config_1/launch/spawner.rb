def spawner(_name, _modelURI, _worldName, _x, _y, _z, _roll, _pitch, _yaw)
  <<-HEREDOC
  <spawn name='#{_name}'>
    <name>#{_name}</name>
    <allow_renaming>false</allow_renaming>
    <pose>#{_x} #{_y} #{_z + 0.19} #{_roll} #{_pitch} #{_yaw}</pose>
    <world>#{_worldName}</world>
    <is_performer>true</is_performer>
    <sdf version='1.6'>
    <include>
      <name>#{_name}</name>
      <uri>#{_modelURI}</uri>

      <!-- Tracked vehicle controller -->
      <plugin name="ignition::gazebo::systems::TrackedVehicle" filename="ignition-gazebo-tracked-vehicle-system">
        <left_track><link>left_track</link></left_track>
        <right_track><link>right_track</link></right_track>
        <tracks_separation>#{0.5}</tracks_separation>
        <tracks_height>0.28</tracks_height>
        <steering_efficiency>0.5</steering_efficiency>
        <topic>/model/#{_name}/cmd_vel_relay</topic>
        <linear_velocity>
          <min_velocity>-1.2</min_velocity>
          <max_velocity>1.2</max_velocity>
          <min_acceleration>-1.0</min_acceleration>
          <max_acceleration>1.0</max_acceleration>
        </linear_velocity>
      </plugin>

      <!-- Joint state for lidar gimbal -->
      <plugin
        filename="libignition-gazebo-joint-controller-system.so"
        name="ignition::gazebo::systems::JointController">
        <joint_name>lidar_gimbal</joint_name>
      </plugin>
      <plugin
        filename="libignition-gazebo-joint-state-publisher-system.so"
        name="ignition::gazebo::systems::JointStatePublisher">
        <joint_name>lidar_gimbal</joint_name>
      </plugin>

      <!-- Publish robot state information -->
      <plugin filename="libignition-gazebo-pose-publisher-system.so"
        name="ignition::gazebo::systems::PosePublisher">
        <publish_link_pose>true</publish_link_pose>
        <publish_sensor_pose>true</publish_sensor_pose>
        <publish_collision_pose>false</publish_collision_pose>
        <publish_visual_pose>false</publish_visual_pose>
        <publish_nested_model_pose>#{$enableGroundTruth}</publish_nested_model_pose>
        <use_pose_vector_msg>true</use_pose_vector_msg>
        <static_pose_publisher>true</static_pose_publisher>
        <static_pose_update_frequency>1</static_pose_update_frequency>
      </plugin>

      <!-- Battery plugin -->
      <plugin filename="libignition-gazebo-linearbatteryplugin-system.so"
        name="ignition::gazebo::systems::LinearBatteryPlugin">
        <battery_name>linear_battery</battery_name>
        <voltage>12.694</voltage>
        <open_circuit_voltage_constant_coef>12.694</open_circuit_voltage_constant_coef>
        <open_circuit_voltage_linear_coef>-3.1424</open_circuit_voltage_linear_coef>
        <initial_charge>78.4</initial_charge>
        <capacity>78.4</capacity>
        <resistance>0.061523</resistance>
        <smooth_current_tau>1.9499</smooth_current_tau>
        <power_load>1.903846154</power_load>
        <start_on_motion>true</start_on_motion>
        <power_draining_topic>/model/#{_name}/link/left_track/track_cmd_vel</power_draining_topic>
        <power_draining_topic>/model/#{_name}/link/right_track/track_cmd_vel</power_draining_topic>
      </plugin>

      <!-- Gas Sensor plugin -->"
      <plugin filename="libGasEmitterDetectorPlugin.so"
        name="subt::GasDetector">
        <topic>/model/#{_name}/gas_detected</topic>
        <update_rate>10</update_rate>
        <type>gas</type>
      </plugin>

    </include>
    </sdf>
  </spawn>
  HEREDOC
end

def rosExecutables(_name, _worldName)
  <<-HEREDOC
  <executable name='robot_description'>
    <command>roslaunch --wait csiro_data61_ozbot_atr_sensor_config_1 description.launch world_name:=#{_worldName} name:=#{_name}</command>
  </executable>
  <executable name='topics'>
    <command>roslaunch --wait csiro_data61_ozbot_atr_sensor_config_1 vehicle_topics.launch world_name:=#{_worldName} name:=#{_name}</command>
  </executable>
  HEREDOC
end
