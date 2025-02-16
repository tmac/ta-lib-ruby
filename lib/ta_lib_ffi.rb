# frozen_string_literal: true

require "fiddle"
require "fiddle/import"

# Ruby FFI wrapper for TA-Lib (Technical Analysis Library)
#
# This module provides a Ruby interface to the TA-Lib technical analysis library
# using FFI (Foreign Function Interface). It allows you to perform various
# technical analysis calculations on financial market data.
#
# @example Basic usage
#   require 'ta_lib_ffi'
#
#   # Calculate Simple Moving Average
#   prices = [10.0, 11.0, 12.0, 11.0, 10.0]
#   result = TALibFFI.sma(prices, time_period: 3)
#
# @see https://ta-lib.org/ TA-Lib Official Website
module TALibFFI
  VERSION = "0.2.0"

  if defined?(Zeitwerk)
    # https://github.com/fxn/zeitwerk?tab=readme-ov-file#custom-inflector
    class Inflector < Zeitwerk::GemInflector
      def camelize(basename, _abspath)
        case basename
        when "ta_lib_ffi"
          "TALibFFI"
        else
          super
        end
      end
    end
  end

  extend Fiddle::Importer

  lib_path = case RUBY_PLATFORM
             when /darwin/
               brew_prefix = `brew --prefix`.chomp
               "#{brew_prefix}/lib/libta-lib.dylib"
             when /linux/
               "libta-lib.so"
             when /cygwin|mswin|mingw|bccwin|wince|emx/
               "C:/Program Files/TA-Lib/bin/ta-lib.dll"
             else
               raise "Unsupported platform"
             end

  dlload lib_path

  class TALibError < StandardError; end

  TA_SUCCESS                    = 0
  TA_LIB_NOT_INITIALIZE         = 1
  TA_BAD_PARAM                  = 2
  TA_ALLOC_ERR                  = 3
  TA_GROUP_NOT_FOUND            = 4
  TA_FUNC_NOT_FOUND             = 5
  TA_INVALID_HANDLE             = 6
  TA_INVALID_PARAM_HOLDER       = 7
  TA_INVALID_PARAM_HOLDER_TYPE  = 8
  TA_INVALID_PARAM_FUNCTION     = 9
  TA_INPUT_NOT_ALL_INITIALIZE   = 10
  TA_OUTPUT_NOT_ALL_INITIALIZE  = 11
  TA_OUT_OF_RANGE_START_INDEX   = 12
  TA_OUT_OF_RANGE_END_INDEX     = 13
  TA_INVALID_LIST_TYPE          = 14
  TA_BAD_OBJECT                 = 15
  TA_NOT_SUPPORTED              = 16
  TA_INTERNAL_ERROR             = 5000
  TA_UNKNOWN_ERR                = 0xFFFF

  # {0,"SMA"},
  # {1,"EMA"},
  # {2,"WMA"},
  # {3,"DEMA" },
  # {4,"TEMA" },
  # {5,"TRIMA"},
  # {6,"KAMA" },
  # {7,"MAMA" },
  # {8,"T3"}

  typealias "TA_Real", "double"
  typealias "TA_Integer", "int"
  typealias "TA_RetCode", "int"
  typealias "TA_FuncHandle", "unsigned int"
  typealias "TA_FuncFlags", "int"
  typealias "TA_CallForEachFunc", "void *"
  typealias "TA_InputParameterType", "int"
  typealias "TA_InputFlags", "int"
  typealias "TA_OptInputParameterType", "int"
  typealias "TA_OptInputFlags", "int"
  typealias "TA_OutputParameterType", "int"
  typealias "TA_OutputFlags", "int"

  TA_StringTable = struct [
    "unsigned int size",
    "const char **string",
    "void *hiddenData"
  ]

  TA_FuncInfo = struct [
    "const char *name",
    "const char *group",
    "const char *hint",
    "const char *camelCaseName",
    "TA_FuncFlags flags",
    "unsigned int nbInput",
    "unsigned int nbOptInput",
    "unsigned int nbOutput",
    "const TA_FuncHandle *handle"
  ]

  TA_ParamHolder = struct [
    "void *hiddenData"
  ]

  TA_InputParameterInfo = struct [
    "TA_InputParameterType type",
    "const char *paramName",
    "TA_InputFlags flags"
  ]

  TA_OptInputParameterInfo = struct [
    "TA_OptInputParameterType type",
    "const char *paramName",
    "TA_OptInputFlags flags",
    "const char *displayName",
    "const void *dataSet",
    "TA_Real defaultValue",
    "const char *hint",
    "const char *helpFile"
  ]

  TA_OutputParameterInfo = struct [
    "TA_OutputParameterType type",
    "const char *paramName",
    "TA_OutputFlags flags"
  ]

  TA_PARAM_TYPE = {
    TA_Input_Price: 0,
    TA_Input_Real: 1,
    TA_Input_Integer: 2,
    TA_OptInput_RealRange: 0,
    TA_OptInput_RealList: 1,
    TA_OptInput_IntegerRange: 2,
    TA_OptInput_IntegerList: 3,
    TA_Output_Real: 0,
    TA_Output_Integer: 1
  }.freeze

  TA_FLAGS = {
    TA_InputFlags: {
      TA_IN_PRICE_OPEN: 0x00000001,
      TA_IN_PRICE_HIGH: 0x00000002,
      TA_IN_PRICE_LOW: 0x00000004,
      TA_IN_PRICE_CLOSE: 0x00000008,
      TA_IN_PRICE_VOLUME: 0x00000010,
      TA_IN_PRICE_OPENINTEREST: 0x00000020,
      TA_IN_PRICE_TIMESTAMP: 0x00000040
    },
    TA_OptInputFlags: {
      TA_OPTIN_IS_PERCENT: 0x00100000,
      TA_OPTIN_IS_DEGREE: 0x00200000,
      TA_OPTIN_IS_CURRENCY: 0x00400000,
      TA_OPTIN_ADVANCED: 0x01000000
    },
    TA_OutputFlags: {
      TA_OUT_LINE: 0x00000001,
      TA_OUT_DOT_LINE: 0x00000002,
      TA_OUT_DASH_LINE: 0x00000004,
      TA_OUT_DOT: 0x00000008,
      TA_OUT_HISTO: 0x00000010,
      TA_OUT_PATTERN_BOOL: 0x00000020,
      TA_OUT_PATTERN_BULL_BEAR: 0x00000040,
      TA_OUT_PATTERN_STRENGTH: 0x00000080,
      TA_OUT_POSITIVE: 0x00000100,
      TA_OUT_NEGATIVE: 0x00000200,
      TA_OUT_ZERO: 0x00000400,
      TA_OUT_UPPER_LIMIT: 0x00000800,
      TA_OUT_LOWER_LIMIT: 0x00001000
    }
  }.freeze

  extern "int TA_Initialize()"
  extern "int TA_Shutdown()"
  extern "int TA_GroupTableAlloc(TA_StringTable**)"
  extern "int TA_GroupTableFree(TA_StringTable*)"
  extern "TA_RetCode TA_FuncTableAlloc(const char *group, TA_StringTable **table)"
  extern "TA_RetCode TA_FuncTableFree(TA_StringTable *table)"
  extern "TA_FuncHandle TA_GetFuncHandle(const char *name, const TA_FuncHandle **handle)"
  extern "TA_RetCode TA_GetFuncInfo(const TA_FuncHandle *handle, const TA_FuncInfo **funcInfo)"
  extern "TA_RetCode TA_ForEachFunc(TA_CallForEachFunc functionToCall, void *opaqueData)"
  extern "TA_RetCode TA_GetInputParameterInfo(const TA_FuncHandle *handle, unsigned int paramIndex, const TA_InputParameterInfo **info)"
  extern "TA_RetCode TA_GetOptInputParameterInfo(const TA_FuncHandle *handle, unsigned int paramIndex, const TA_OptInputParameterInfo **info)"
  extern "TA_RetCode TA_GetOutputParameterInfo(const TA_FuncHandle *handle, unsigned int paramIndex, const TA_OutputParameterInfo **info)"
  extern "TA_RetCode TA_ParamHolderAlloc(const TA_FuncHandle *handle, TA_ParamHolder **allocatedParams)"
  extern "TA_RetCode TA_ParamHolderFree(TA_ParamHolder *params)"
  extern "TA_RetCode TA_SetInputParamIntegerPtr(TA_ParamHolder *params, unsigned int paramIndex, const TA_Integer *value)"
  extern "TA_RetCode TA_SetInputParamRealPtr(TA_ParamHolder *params, unsigned int paramIndex, const TA_Real *value)"
  extern "TA_RetCode TA_SetInputParamPricePtr(TA_ParamHolder *params,
                                             unsigned int paramIndex,
                                             const TA_Real *open,
                                             const TA_Real *high,
                                             const TA_Real *low,
                                             const TA_Real *close,
                                             const TA_Real *volume,
                                             const TA_Real *openInterest)"
  extern "TA_RetCode TA_SetOptInputParamInteger(TA_ParamHolder *params, unsigned int paramIndex, TA_Integer optInValue)"
  extern "TA_RetCode TA_SetOptInputParamReal(TA_ParamHolder *params, unsigned int paramIndex, TA_Real optInValue)"
  extern "TA_RetCode TA_SetOutputParamIntegerPtr(TA_ParamHolder *params, unsigned int paramIndex, TA_Integer *out)"
  extern "TA_RetCode TA_SetOutputParamRealPtr(TA_ParamHolder *params, unsigned int paramIndex, TA_Real *out)"
  extern "TA_RetCode TA_GetLookback(const TA_ParamHolder *params, TA_Integer *lookback)"
  extern "TA_RetCode TA_CallFunc(const TA_ParamHolder *params,
                                TA_Integer startIdx,
                                TA_Integer endIdx,
                                TA_Integer *outBegIdx,
                                TA_Integer *outNbElement)"
  extern "const char *TA_FunctionDescriptionXML(void)"

  module_function

  # Extracts flags from a bitmask value based on the flag type
  #
  # @param value [Integer] The bitmask value to extract flags from
  # @param type [Symbol] The type of flags to extract (:TA_InputFlags, :TA_OptInputFlags, or :TA_OutputFlags)
  # @return [Array<Symbol>] Array of flag names that are set in the bitmask
  def extract_flags(value, type)
    flags_set = []
    TA_FLAGS[type].each do |k, v|
      flags_set << k if (value & v) != 0
    end
    flags_set
  end

  # Returns a list of all available function groups in TA-Lib
  #
  # @return [Array<String>] Array of group names
  def group_table
    string_table_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
    ret_code = TA_GroupTableAlloc(string_table_ptr.ref)
    check_ta_return_code(ret_code)

    string_table = TA_StringTable.new(string_table_ptr)
    group_names = Fiddle::Pointer.new(string_table["string"])[0, Fiddle::SIZEOF_VOIDP * string_table["size"]].unpack("Q*").collect { |ptr| Fiddle::Pointer.new(ptr).to_s }
    TA_GroupTableFree(string_table_ptr)

    group_names
  end

  # Returns a list of all functions in a specific group
  #
  # @param group [String] The name of the group to get functions for
  # @return [Array<String>] Array of function names in the group
  def function_table(group)
    string_table_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
    ret_code = TA_FuncTableAlloc(group, string_table_ptr.ref)
    check_ta_return_code(ret_code)

    string_table = TA_StringTable.new(string_table_ptr)
    func_names = Fiddle::Pointer.new(string_table["string"])[0, Fiddle::SIZEOF_VOIDP * string_table["size"]].unpack("Q*").collect { |ptr| Fiddle::Pointer.new(ptr).to_s }

    TA_FuncTableFree(string_table)

    func_names
  end

  # Gets detailed information about a specific TA-Lib function
  #
  # @param name [String] The name of the function to get information for
  # @return [Fiddle::CStructEntity] Struct containing function information
  def function_info(name)
    handle_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
    ret_code = TA_GetFuncHandle(name, handle_ptr.ref)
    check_ta_return_code(ret_code)

    info_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
    ret_code = TA_GetFuncInfo(handle_ptr, info_ptr.ref)
    check_ta_return_code(ret_code)

    TA_FuncInfo.new(info_ptr)
  end

  # Iterates over all available TA-Lib functions
  #
  # @yield [func_info] Yields function information for each function
  # @yieldparam func_info [Fiddle::CStructEntity] Function information struct
  def each_function(&block)
    callback = Fiddle::Closure::BlockCaller.new(
      Fiddle::TYPE_VOID,
      [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP],
      Fiddle::Function::DEFAULT
    ) do |func_info_ptr, _|
      block.call TA_FuncInfo.new(func_info_ptr)
    end

    ret_code = TA_ForEachFunc(callback, nil)
    check_ta_return_code(ret_code)
  end

  # Prints detailed information about a TA-Lib function
  #
  # @param func_info [Fiddle::CStructEntity] Function information struct to print
  def print_function_info(func_info) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    puts "Function Name: #{func_info["name"]}"
    puts "Function Group: #{func_info["group"]}"
    puts "Function Hint: #{func_info["hint"]}"
    puts "Camel Case Name: #{func_info["camelCaseName"]}"
    puts "Flags: #{func_info["flags"]}"
    puts "Number of Inputs: #{func_info["nbInput"]}"
    puts "Number of Optional Inputs: #{func_info["nbOptInput"]}"
    puts "Number of Outputs: #{func_info["nbOutput"]}"
    puts "Function Handle: #{func_info["handle"].to_i}"

    puts "\nInput Parameter Info:"
    func_info["nbInput"].times do |i|
      param_info_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
      ret_code = TA_GetInputParameterInfo(func_info["handle"], i, param_info_ptr.ref)
      check_ta_return_code(ret_code)
      param_info = TA_InputParameterInfo.new(param_info_ptr)
      puts "  Parameter #{i + 1}:"
      puts "    Name: #{param_info["paramName"]}"
      puts "    Type: #{param_info["type"]}"
      puts "    Flags: #{extract_flags(param_info["flags"], :TA_InputFlags)}"
    end

    puts "\nOptional Input Parameter Info:"
    func_info["nbOptInput"].times do |i|
      param_info_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
      ret_code = TA_GetOptInputParameterInfo(func_info["handle"], i, param_info_ptr.ref)
      check_ta_return_code(ret_code)
      param_info = TA_OptInputParameterInfo.new(param_info_ptr)
      puts "  Parameter #{i + 1}:"
      puts "    Name: #{param_info["paramName"]}"
      puts "    Type: #{param_info["type"]}"
      puts "    Flags: #{extract_flags(param_info["flags"], :TA_OptInputFlags)}"
      puts "    Display Name: #{param_info["displayName"]}"
      puts "    Default Value: #{param_info["defaultValue"]}"
      puts "    Hint: #{param_info["hint"]}"
    end

    puts "\nOutput Parameter Info:"
    func_info["nbOutput"].times do |i|
      param_info_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
      ret_code = TA_GetOutputParameterInfo(func_info["handle"], i, param_info_ptr.ref)
      check_ta_return_code(ret_code)
      param_info = TA_OutputParameterInfo.new(param_info_ptr)
      puts "  Parameter #{i + 1}:"
      puts "    Name: #{param_info["paramName"]}"
      puts "    Type: #{param_info["type"]}"
      puts "    Flags: #{extract_flags(param_info["flags"], :TA_OutputFlags)}"
    end
  end

  # Calls a TA-Lib function with the given arguments
  #
  # @param func_name [String] The name of the function to call
  # @param args [Array] Array of input arrays and optional parameters
  # @return [Array, Hash] Function results (single array or hash of named outputs)
  # @raise [TALibError] If there is an error in function execution
  def call_func(func_name, args) # rubocop:disable Metrics/MethodLength
    options = args.last.is_a?(Hash) ? args.pop : {}
    input_arrays = args

    validate_inputs!(input_arrays)

    handle_ptr = get_function_handle(func_name)
    params_ptr = create_parameter_holder(handle_ptr)

    begin
      setup_input_parameters(params_ptr, input_arrays, func_name)
      setup_optional_parameters(params_ptr, options, func_name)
      _lookback = calculate_lookback(params_ptr)
      calculate_results(params_ptr, input_arrays.first.length, func_name)
    ensure
      TA_ParamHolderFree(params_ptr)
    end
  end

  # Calculates the lookback period for a function with given parameters
  #
  # @param params_ptr [Fiddle::Pointer] Pointer to parameter holder
  # @return [Integer] The lookback period
  def calculate_lookback(params_ptr)
    lookback_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT)
    ret_code = TA_GetLookback(params_ptr, lookback_ptr)
    check_ta_return_code(ret_code)
    lookback_ptr[0, Fiddle::SIZEOF_INT].unpack1("l")
  end

  # Validates input arrays for TA-Lib functions
  #
  # @param arrays [Array<Array>] Arrays to validate
  # @raise [TALibError] If any array is invalid
  def validate_inputs!(arrays) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    raise TALibError, "Input arrays cannot be empty" if arrays.empty?

    arrays.each do |arr|
      raise TALibError, "Input must be arrays" unless arr.is_a?(Array)
    end

    sizes = arrays.map(&:length)
    raise TALibError, "Input arrays cannot be empty" if sizes.any?(&:zero?)

    arrays.each do |arr|
      raise TALibError, "Input arrays must contain only numbers" unless arr.flatten.all? { |x| x.is_a?(Numeric) }
    end
  end

  # Gets a function handle for a given function name
  #
  # @param func_name [String] The name of the function
  # @return [Fiddle::Pointer] Pointer to function handle
  def get_function_handle(func_name)
    handle_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
    ret_code = TA_GetFuncHandle(func_name, handle_ptr.ref)
    check_ta_return_code(ret_code)
    handle_ptr
  end

  # Creates a parameter holder for a function
  #
  # @param handle_ptr [Fiddle::Pointer] Function handle pointer
  # @return [Fiddle::Pointer] Pointer to parameter holder
  def create_parameter_holder(handle_ptr)
    params_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
    ret_code = TA_ParamHolderAlloc(handle_ptr, params_ptr.ref)
    check_ta_return_code(ret_code)
    params_ptr
  end

  # Sets up input parameters for a function call
  #
  # @param params_ptr [Fiddle::Pointer] Parameter holder pointer
  # @param input_arrays [Array<Array>] Input data arrays
  # @param func_name [String] Function name
  def setup_input_parameters(params_ptr, input_arrays, func_name)
    func_info = function_info_map[func_name]
    input_arrays.each_with_index do |array, index|
      input_info = func_info[:inputs][index]
      ret_code = set_input_parameter(params_ptr, index, array, input_info)
      check_ta_return_code(ret_code)
    end
  end

  # Sets a single input parameter
  #
  # @param params_ptr [Fiddle::Pointer] Parameter holder pointer
  # @param index [Integer] Parameter index
  # @param array [Array] Input data array
  # @param input_info [Hash] Input parameter information
  # @return [Integer] TA-Lib return code
  def set_input_parameter(params_ptr, index, array, input_info)
    case input_info["type"]
    when TA_PARAM_TYPE[:TA_Input_Real]
      input_ptr = prepare_double_array(array)
      TA_SetInputParamRealPtr(params_ptr, index, input_ptr)
    when TA_PARAM_TYPE[:TA_Input_Integer]
      input_ptr = prepare_integer_array(array)
      TA_SetInputParamIntegerPtr(params_ptr, index, input_ptr)
    when TA_PARAM_TYPE[:TA_Input_Price]
      setup_price_inputs(params_ptr, index, array, input_info["flags"])
    end
  end

  # Prepares a double array for TA-Lib input
  #
  # @param array [Array<Numeric>] Array of numbers to prepare
  # @return [Fiddle::Pointer] Pointer to prepared array
  def prepare_double_array(array)
    array_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE * array.length)
    array.each_with_index do |value, i|
      array_ptr[i * Fiddle::SIZEOF_DOUBLE, Fiddle::SIZEOF_DOUBLE] = [value.to_f].pack("d")
    end
    array_ptr
  end

  # Prepares an integer array for TA-Lib input
  #
  # @param array [Array<Numeric>] Array of numbers to prepare
  # @return [Fiddle::Pointer] Pointer to prepared array
  def prepare_integer_array(array)
    array_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT * array.length)
    array.each_with_index do |value, i|
      array_ptr[i * Fiddle::SIZEOF_INT, Fiddle::SIZEOF_INT] = [value.to_i].pack("l")
    end
    array_ptr
  end

  # Sets up optional parameters for a function call
  #
  # @param params_ptr [Fiddle::Pointer] Parameter holder pointer
  # @param options [Hash] Optional parameters
  # @param func_name [String] Function name
  def setup_optional_parameters(params_ptr, options, func_name)
    func_info = function_info_map[func_name]
    func_info[:opt_inputs]&.each_with_index do |opt_input, index|
      param_name = normalize_parameter_name(opt_input["paramName"].to_s)
      set_optional_parameter(params_ptr, index, options[param_name.to_sym], opt_input["type"]) if options.key?(param_name.to_sym)
    end
  end

  # Sets a single optional parameter
  #
  # @param params_ptr [Fiddle::Pointer] Parameter holder pointer
  # @param index [Integer] Parameter index
  # @param value [Numeric] Parameter value
  # @param type [Integer] Parameter type
  def set_optional_parameter(params_ptr, index, value, type)
    case type
    when TA_PARAM_TYPE[:TA_OptInput_RealRange], TA_PARAM_TYPE[:TA_OptInput_RealList]
      ret_code = TA_SetOptInputParamReal(params_ptr, index, value)
    when TA_PARAM_TYPE[:TA_OptInput_IntegerRange], TA_PARAM_TYPE[:TA_OptInput_IntegerList]
      ret_code = TA_SetOptInputParamInteger(params_ptr, index, value)
    end
    check_ta_return_code(ret_code)
  end

  # Calculates function results
  #
  # @param params_ptr [Fiddle::Pointer] Parameter holder pointer
  # @param input_size [Integer] Size of input data
  # @param func_name [String] Function name
  # @return [Array, Hash] Function results
  def calculate_results(params_ptr, input_size, func_name) # rubocop:disable Metrics/MethodLength
    out_begin = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT)
    out_size = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT)
    output_arrays = setup_output_buffers(params_ptr, input_size, func_name)

    begin
      ret_code = TA_CallFunc(params_ptr, 0, input_size - 1, out_begin, out_size)
      check_ta_return_code(ret_code)

      actual_size = out_size[0, Fiddle::SIZEOF_INT].unpack1("l")
      format_output_results(output_arrays, actual_size, func_name)
    ensure
      out_begin.free
      out_size.free
      output_arrays.each(&:free)
    end
  end

  # Sets up output buffers for function results
  #
  # @param params_ptr [Fiddle::Pointer] Parameter holder pointer
  # @param size [Integer] Size of output buffer
  # @param func_name [String] Function name
  # @return [Array<Fiddle::Pointer>] Array of output buffer pointers
  def setup_output_buffers(params_ptr, size, func_name) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    func_info = function_info_map[func_name]
    output_ptrs = []

    func_info[:outputs].each_with_index do |output, index|
      ptr = case output["type"]
            when TA_PARAM_TYPE[:TA_Output_Real]
              Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE * size)
            when TA_PARAM_TYPE[:TA_Output_Integer]
              Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT * size)
            end

      output_ptrs << ptr

      ret_code =  case output["type"]
                  when TA_PARAM_TYPE[:TA_Output_Real]
                    TA_SetOutputParamRealPtr(params_ptr, index, ptr)
                  when TA_PARAM_TYPE[:TA_Output_Integer]
                    TA_SetOutputParamIntegerPtr(params_ptr, index, ptr)
                  end

      check_ta_return_code(ret_code)
    end

    output_ptrs
  end

  # Formats output results from TA-Lib function
  #
  # @param output_ptrs [Array<Fiddle::Pointer>] Array of output buffer pointers
  # @param size [Integer] Size of output data
  # @param func_name [String] Function name
  # @return [Array, Hash] Formatted results
  def format_output_results(output_ptrs, size, func_name) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    func_info = function_info_map[func_name]
    results = output_ptrs.zip(func_info[:outputs]).map do |ptr, output|
      case output["type"]
      when TA_PARAM_TYPE[:TA_Output_Real]
        ptr[0, Fiddle::SIZEOF_DOUBLE * size].unpack("d#{size}")
      when TA_PARAM_TYPE[:TA_Output_Integer]
        ptr[0, Fiddle::SIZEOF_INT * size].unpack("l#{size}")
      end
    end

    return results.first if results.length == 1

    output_names = func_info[:outputs].map do |output|
      normalize_parameter_name(output["paramName"].to_s).to_sym
    end
    output_names.zip(results).to_h
  end

  # Gets XML description of all TA-Lib functions
  #
  # @return [String] XML function descriptions
  def function_description_xml
    TA_FunctionDescriptionXML().to_s
  end

  # Gets or builds the function information map
  #
  # @return [Hash] Map of function information
  def function_info_map
    @function_info_map ||= build_function_info_map
  end

  # Builds a map of function information for all functions
  #
  # @return [Hash] Map of function information
  def build_function_info_map
    info_map = {}
    each_function do |func_info|
      info_map[func_info["name"].to_s] = {
        info: func_info,
        inputs: collect_input_info(func_info),
        outputs: collect_output_info(func_info),
        opt_inputs: collect_opt_input_info(func_info)
      }
    end
    info_map
  end

  # Collects input parameter information for a function
  #
  # @param func_info [Fiddle::CStructEntity] Function information
  # @return [Array<Fiddle::CStructEntity>] Array of input parameter information
  def collect_input_info(func_info)
    func_info["nbInput"].times.map do |i|
      param_info_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
      TA_GetInputParameterInfo(func_info["handle"], i, param_info_ptr.ref)
      TA_InputParameterInfo.new(param_info_ptr)
    end
  end

  # Collects optional input parameter information for a function
  #
  # @param func_info [Fiddle::CStructEntity] Function information
  # @return [Array<Fiddle::CStructEntity>] Array of optional input parameter information
  def collect_opt_input_info(func_info)
    func_info["nbOptInput"].times.map do |i|
      param_info_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
      TA_GetOptInputParameterInfo(func_info["handle"], i, param_info_ptr.ref)
      TA_OptInputParameterInfo.new(param_info_ptr)
    end
  end

  # Collects output parameter information for a function
  #
  # @param func_info [Fiddle::CStructEntity] Function information
  # @return [Array<Fiddle::CStructEntity>] Array of output parameter information
  def collect_output_info(func_info)
    func_info["nbOutput"].times.map do |i|
      param_info_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
      TA_GetOutputParameterInfo(func_info["handle"], i, param_info_ptr.ref)
      TA_OutputParameterInfo.new(param_info_ptr)
    end
  end

  # Generates Ruby methods for all TA-Lib functions
  #
  # This method iterates through all available TA-Lib functions and creates
  # corresponding Ruby methods with proper documentation.
  def generate_ta_functions
    each_function do |func_info|
      define_ta_function(func_info["name"].to_s.downcase, func_info["name"].to_s)
    end
  end

  # Normalizes parameter names to Ruby style
  #
  # @param name [String] Parameter name to normalize
  # @return [String] Normalized parameter name
  def normalize_parameter_name(name)
    name.sub(/^(optIn|outReal|outInteger|out|in)/, "")
        .gsub(/::/, "/")
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr("-", "_")
        .downcase
  end

  # Checks TA-Lib return codes and raises appropriate errors
  #
  # @param code [Integer] TA-Lib return code
  # @raise [TALibError] If the return code indicates an error
  def check_ta_return_code(code) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
    return if code == TA_SUCCESS

    error_message = case code
                    when TA_LIB_NOT_INITIALIZE
                      "TA-Lib not initialized, please call TA_Initialize first"
                    when TA_BAD_PARAM
                      "Bad parameter, please check input parameters"
                    when TA_ALLOC_ERR
                      "Memory allocation error, possibly insufficient memory"
                    when TA_GROUP_NOT_FOUND
                      "Function group not found"
                    when TA_FUNC_NOT_FOUND
                      "Function not found"
                    when TA_INVALID_HANDLE
                      "Invalid handle"
                    when TA_INVALID_PARAM_HOLDER
                      "Invalid parameter holder"
                    when TA_INVALID_PARAM_HOLDER_TYPE
                      "Invalid parameter holder type"
                    when TA_INVALID_PARAM_FUNCTION
                      "Invalid parameter function"
                    when TA_INPUT_NOT_ALL_INITIALIZE
                      "Input parameters not fully initialized"
                    when TA_OUTPUT_NOT_ALL_INITIALIZE
                      "Output parameters not fully initialized"
                    when TA_OUT_OF_RANGE_START_INDEX
                      "Start index out of range"
                    when TA_OUT_OF_RANGE_END_INDEX
                      "End index out of range"
                    when TA_INVALID_LIST_TYPE
                      "Invalid list type"
                    when TA_BAD_OBJECT
                      "Invalid object"
                    when TA_NOT_SUPPORTED
                      "Operation not supported"
                    when TA_INTERNAL_ERROR
                      "TA-Lib internal error"
                    when TA_UNKNOWN_ERR
                      "Unknown error"
                    else
                      "Undefined TA-Lib error (Error code: #{code})"
                    end

    raise TALibError, error_message
  end

  # Initializes the TA-Lib library
  def initialize_ta_lib
    return if @initialized

    ret_code = TA_Initialize()
    check_ta_return_code(ret_code)
    at_exit { TA_Shutdown() }
    @initialized = true
  end

  # Defines a TA-Lib function as a Ruby method with documentation
  #
  # @param method_name [String] Name of the Ruby method to define
  # @param func_name [String] Name of the TA-Lib function
  def define_ta_function(method_name, func_name)
    define_singleton_method(method_name) do |*args|
      call_func(func_name, args)
    end
  end

  # Sets up price inputs for functions that take price data
  #
  # @param params_ptr [Fiddle::Pointer] Parameter holder pointer
  # @param index [Integer] Parameter index
  # @param price_data [Array] Price data array
  # @param flags [Integer] Input flags
  def setup_price_inputs(params_ptr, index, price_data, flags)
    required_flags = extract_flags(flags, :TA_InputFlags)
    data_pointers = Array.new(6) { nil }
    TA_FLAGS[:TA_InputFlags].keys[0..5].each_with_index do |flag, i|
      data_pointers[i] = if required_flags.include?(flag)
                           prepare_double_array(price_data[required_flags.index(flag)])
                         else
                           Fiddle::Pointer.malloc(0)
                         end
    end

    TA_SetInputParamPricePtr(params_ptr, index, *data_pointers)
  end

  initialize_ta_lib
  generate_ta_functions

  # Placeholder for generated TA-Lib function documentation.
  # Generated using YARD.
  # Run: rake yard
  class << self
    ### GENERATED DOCUMENTATION START ###
    ### GENERATED DOCUMENTATION END ###
  end
end
