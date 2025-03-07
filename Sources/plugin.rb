#
//  plugin.rb
//  Pods
//
//  Created by Akash Tala on 11/02/25.
//

module Pod
  class Installer
    class Xcode
      class PodsProjectGenerator
        class PodfileModifier
          def self.modify_podfile(podfile_path)
            content = File.read(podfile_path)
            
            # Check if the line is already present to avoid duplicates
            unless content.include?("install! 'cocoapods', :preserve_pod_file_structure => true")
              content.prepend("install! 'cocoapods', :preserve_pod_file_structure => true\n\n")
              File.write(podfile_path, content)
              puts "[Custom Pod] Modified Podfile to include preserve_pod_file_structure option."
            end
          end
        end
      end
    end
  end
end
