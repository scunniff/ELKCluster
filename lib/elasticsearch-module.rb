module Vagrant
    module ElastiSearchCluster
        class Util
            attr_accessor :logger

            def get_dot_vagrant
                File.join(File.dirname(__FILE__),'..','.vagrant')
            end

            def get_conf_dir
                File.join(File.dirname(__FILE__),'..','conf')
            end

            def initialize
                @params = [
                    'cluster_name' => ['CLUSTER_NAME', 'cluster_name', 'dev-es-cluster'],
                    'cluster_ip' => ['CLUSTER_IP_PATTERN', 'cluster_ip', '10.1.1.%d'],
                    'cluster_count' => ['CLUSTER_COUNT', 'cluster_count', 1],
                    'cluster_ram' => ['CLUSTER_RAM', 'cluster_ram', 1024],
                    'cluster_cpu' => ['CLUSTER_CPU', 'cluster_cpu', 1],
                ]

                @names = %w(thor zeus isis shifu baal)
                @logger = Vagrant::UI::Colored.new
                @logger.opts[:color] = :white
            end

            def get_vm_name(index)
                "vm#{index}"
            end

            def get_vm_ip(index)
                ip = get_cluster_info 'cluster_ip'
                ip.strip % (10 + index)
            end

            def get_node_name(index)
                @names[index - 1]
            end

            def get_kibana_vm_name
                "vm250"
            end

            def get_kibana_vm_ip
                ip = get_cluster_info 'cluster_ip'
                ip.strip % 250
            end

            def get_kibana_node_name
                "kibana"
            end

            def get_logstash_vm_name
                "vm251"
            end

            def get_logstash_vm_ip
                ip = get_cluster_info 'cluster_ip'
                ip.strip % 251
            end

            def get_logstash_node_name
                "logstash"
            end

            def get_cluster_info(index)
                return ENV[@params[0][index][0]] if ENV[@params[0][index][0]]
                dot_vagrant = get_dot_vagrant()
                return (File.read "#{dot_vagrant}/#{@params[0][index][1]}") if File.exist? "#{dot_vagrant}/#{@params[0][index][1]}"
                "#{@params[0][index][2]}"
            end

            def save_cluster_info(index, value)
                dot_vagrant = get_dot_vagrant()
                Dir.mkdir("#{dot_vagrant}") unless Dir.exist?("#{dot_vagrant}")
                File.open("#{dot_vagrant}/#{@params[0][index][1]}", 'w') do |file|
                    file.puts value.to_s
                end
            end

            def get_config_template
                conf_dir = get_conf_dir()
                config_file = File.open("#{conf_dir}/elasticsearch.yml.erb", 'r')
                ERB.new(config_file.read)
            end

            def get_logstash_config_template
                conf_dir = get_conf_dir()
                config_file = File.open("#{conf_dir}/logstash.conf.erb", 'r')
                ERB.new(config_file.read)
            end

            def build_config(index)
                vm = get_vm_name index
                conf_dir = get_conf_dir()
                conf_file_format = "#{conf_dir}/elasticsearch-#{vm}.yml"

                File.open(conf_file_format, 'w') do |file|
                    @vm_name = vm
                    @node01_ip = get_vm_ip 1
                    @node_ip = get_vm_ip index
                    @node_name = get_node_name index
                    @node_master = true
                    @node_data = true
                    @cluster_ip = get_cluster_info 'cluster_ip'
                    @cluster_name = get_cluster_info 'cluster_name'

                    @logger.info "Building configuration for #{vm}"
                    file.puts self.get_config_template.result(binding)
                end unless File.exist? conf_file_format
            end

            def build_kibana_config
                vm = get_kibana_vm_name
                conf_dir = get_conf_dir()
                conf_file_format = "#{conf_dir}/elasticsearch-#{vm}.yml"

                File.open(conf_file_format, 'w') do |file|
                    @vm_name = vm
                    @node_ip = get_kibana_vm_ip
                    @node_name = get_kibana_node_name
                    @node_master = false
                    @node_data = false
                    @cluster_ip = get_cluster_info 'cluster_ip'
                    @cluster_name = get_cluster_info 'cluster_name'

                    @logger.info "Building configuration for #{vm}"
                    file.puts self.get_config_template.result(binding)
                end unless File.exist? conf_file_format
            end

            def build_logstash_config
                vm = get_logstash_vm_name
                conf_dir = get_conf_dir()
                conf_file_format = "#{conf_dir}/logstash-#{vm}.conf"

                File.open(conf_file_format, 'w') do |file|
                    @node01_ip = get_vm_ip 1
                    @cluster_name = get_cluster_info 'cluster_name'
                    @logger.info "Building configuration for #{vm}"
                    file.puts self.get_logstash_config_template.result(binding)
                end unless File.exist? conf_file_format
            end

            def manage_and_print_config
                self.logger.info "----------------------------------------------------------"
                self.logger.info "          Your ES cluster configurations"
                self.logger.info "----------------------------------------------------------"

                # Building and showing CLUSTER NAME information
                index = 'cluster_name'
                cluster_name = self.get_cluster_info index
                self.logger.info "Cluster Name: #{cluster_name.strip}"
                self.save_cluster_info index, cluster_name

                # Building and showing CLUSTER COUNT information
                index = 'cluster_count'
                nodes_number = self.get_cluster_info index
                self.logger.info "Cluster size: #{nodes_number.strip}"
                self.save_cluster_info index, nodes_number

                # Building and showing CLUSTER IP PATTERN information
                index = 'cluster_ip'
                cluster_network_ip = self.get_cluster_info index
                self.logger.info "Cluster network IP: #{cluster_network_ip.strip % 0}"
                self.save_cluster_info index, cluster_network_ip

                # Building and showing CLUSTER RAM information
                index = 'cluster_ram'
                cluster_ram = self.get_cluster_info index
                self.logger.info "Cluster RAM (for each node): #{cluster_ram.strip}"
                self.save_cluster_info index, cluster_ram
                #
                # Building and showing CLUSTER RAM information
                index = 'cluster_cpu'
                cluster_cpu = self.get_cluster_info index
                self.logger.info "Cluster CPU (for each node): #{cluster_cpu.strip}"
                self.save_cluster_info index, cluster_cpu

                self.logger.info "----------------------------------------------------------"
            end
        end
    end
end

