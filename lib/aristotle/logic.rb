module Aristotle
  class Logic
    def initialize(object)
      @object = object
    end

    def process(logic_method, return_command: false)
      self.class.commands(logic_method).each do |command|
        next unless command.condition_passes_with?(@object)

        return_value = command.do_action_with(@object)

        return return_command ? command : return_value
      end

      nil
    end

    def self.custom_aristotles_logic_file(file)
      @custom_aristotles_logic_file = file
    end

    def self.commands(logic_method = nil)
      load_commands
      logic_method.nil? ? @commands : (@commands[logic_method] || [])
    end

    # called when class is loaded
    def self.condition(expression, &block)
      @conditions ||= {}
      @conditions[expression] = block
    end

    # called when class is loaded
    def self.action(expression, &block)
      @actions ||= {}
      @actions[expression] = block
    end

    def self.load_commands
      @commands ||= {}

      return if @commands != {}

      if @custom_aristotles_logic_file
        file_path = "#{@custom_aristotles_logic_file}"
      else
        file_path = "app/logic/#{logic_name}"
      end
      filename = "#{file_path}.logic"

      logic_data = File.read(filename)

      command = nil

      lines = logic_data.split("\n").map(&:rstrip).select { |l| l != '' && !l.strip.start_with?('#') }
      lines.each do |line|
        if line.start_with? '  '
          raise "#{filename} is broken!" if command.nil?

          @commands[command] ||= []
          @commands[command] << Aristotle::Command.new(line.strip, @conditions || {}, @actions || {})
        else
          command = line
        end
      end
    end

    def self.html_rules
      Aristotle::Presenter.new(self).html_rules
    end

    def self.logic_name
      self.to_s.gsub(/Logic$/, '').gsub(/([a-z])([A-Z])/, '\1_\2').downcase
    end
  end
end
