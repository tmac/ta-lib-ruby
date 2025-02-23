# frozen_string_literal: true

module TALibFFI
  # Generates documentation for a TA-Lib function
  #
  # This module provides methods to generate documentation for TA-Lib functions.
  # It includes methods to collect input, optional input, and output information,
  # and to generate documentation for each function.
  module Doc
    module_function

    def insert
      puts "Inserting documentation"
      file_path = File.expand_path("../ta_lib_ffi.rb", __dir__)
      content = File.read(file_path)

      new_content = content.sub(
        /### GENERATED DOCUMENTATION START ###.*### GENERATED DOCUMENTATION END ###/m,
        "### GENERATED DOCUMENTATION START ###\n#{generate}\n    ### GENERATED DOCUMENTATION END ###"
      )

      File.write(file_path, new_content)
    end

    def remove
      puts "Removing documentation"
      file_path = File.expand_path("../ta_lib_ffi.rb", __dir__)
      content = File.read(file_path)

      new_content = content.sub(
        /### GENERATED DOCUMENTATION START ###.*### GENERATED DOCUMENTATION END ###/m,
        "### GENERATED DOCUMENTATION START ###\n    ### GENERATED DOCUMENTATION END ###"
      )

      File.write(file_path, new_content)
    end

    def generate
      docs = []
      TALibFFI.function_info_map.each_value do |h|
        docs << generate_function_documentation(h[:info], h[:inputs], h[:opt_inputs], h[:outputs])
      end
      docs.join("\n")
    end

    def generate_function_documentation(func_info, inputs, opt_inputs, outputs)
      [
        generate_function_description(func_info, inputs, opt_inputs),
        generate_input_documentation(inputs),
        generate_optional_input_documentation(opt_inputs),
        generate_output_documentation(outputs),
        generate_error_documentation
      ].flatten.compact.join("\n")
    end

    def generate_function_description(func_info, inputs, opt_inputs) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      args = []
      inputs.map do |input|
        args << TALibFFI.normalize_parameter_name(input["paramName"].to_s)
      end

      opt_inputs.map do |opt_input|
        param_name = TALibFFI.normalize_parameter_name(opt_input["paramName"].to_s)
        args << "#{param_name}: #{opt_input["defaultValue"]}"
      end

      [
        "    # @!method #{func_info["name"].to_s.downcase}(#{args.join(", ")})",
        "    # #{func_info["hint"].to_s.strip}",
        "    #"
      ]
    end

    def generate_input_documentation(inputs) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      inputs.map do |input| # rubocop:disable Metrics/BlockLength
        param_name = TALibFFI.normalize_parameter_name(input["paramName"].to_s)
        flags = TALibFFI.extract_flags(input["flags"], :TA_InputFlags)

        type = case input["type"]
               when TALibFFI::TA_PARAM_TYPE[:TA_Input_Price]
                 array_types = Array.new(flags.length, "Array<Float>")
                 "Array(#{array_types.join(", ")})"
               when TALibFFI::TA_PARAM_TYPE[:TA_Input_Real]
                 "Array<Float>"
               when TALibFFI::TA_PARAM_TYPE[:TA_Input_Integer]
                 "Array<Integer>"
               end

        description = if input["type"] == TALibFFI::TA_PARAM_TYPE[:TA_Input_Price]
                        arrays = flags.map do |flag|
                          {
                            TA_IN_PRICE_OPEN: "open",
                            TA_IN_PRICE_HIGH: "high",
                            TA_IN_PRICE_LOW: "low",
                            TA_IN_PRICE_CLOSE: "close",
                            TA_IN_PRICE_VOLUME: "volume",
                            TA_IN_PRICE_OPENINTEREST: "open interest",
                            TA_IN_PRICE_TIMESTAMP: "timestamp"
                          }[flag]
                        end
                        "Required price arrays: #{arrays.join(", ")}"
                      else
                        "Input values"
                      end

        "    # @param #{param_name} [#{type}]  #{description}"
      end
    end

    def generate_optional_input_documentation(opt_inputs)
      opt_inputs.map do |opt_input|
        param_name = TALibFFI.normalize_parameter_name(opt_input["paramName"].to_s)
        type = opt_input["type"] == TALibFFI::TA_PARAM_TYPE[:TA_OptInput_RealRange] ? "Float" : "Integer"
        "    # @param #{param_name} [#{type}]  #{opt_input["hint"]} (default: #{opt_input["defaultValue"]})"
      end
    end

    def generate_output_documentation(outputs) # rubocop:disable Metrics/MethodLength
      if outputs.length == 1
        type = outputs.first["type"] == TALibFFI::TA_PARAM_TYPE[:TA_Output_Real] ? "Float" : "Integer"
        ["    # @return [Array<#{type}>]"]
      else
        [
          "    # @return [Hash]  Hash containing the following arrays:",
          *outputs.map do |output|
            param_name = TALibFFI.normalize_parameter_name(output["paramName"].to_s)
            type = output["type"] == TALibFFI::TA_PARAM_TYPE[:TA_Output_Real] ? "Float" : "Integer"
            "    # @option result [Array<#{type}>] :#{param_name}  Output values"
          end
        ]
      end
    end

    def generate_error_documentation
      "    # @raise [TALibError]  If there is an error in function execution\n"
    end
  end
end
