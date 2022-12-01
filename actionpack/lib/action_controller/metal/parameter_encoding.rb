# frozen_string_literal: true

module ActionController
  # Specify binary encoding for parameters for a given action.
  module ParameterEncoding
    extend ActiveSupport::Concern

    module ClassMethods
      def inherited(klass) # :nodoc:
        super
        klass.setup_param_encode
      end

      def setup_param_encode # :nodoc:
        @_parameter_encodings = Hash.new { |h, k| h[k] = {} }
      end

      def action_encoding_template(action) # :nodoc:
        if @_parameter_encodings.has_key?(action.to_s)
          @_parameter_encodings[action.to_s]
        end
      end

      # Specify that a given action's parameters should all be encoded as
      # ASCII-8BIT (it "skips" the encoding default of UTF-8).
      #
      # For example, a controller would use it like this:
      #
      #   class RepositoryController < ActionController::Base
      #     skip_parameter_encoding :show
      #
      #     def show
      #       @repo = Repository.find_by_filesystem_path params[:file_path]
      #
      #       # `repo_name` is guaranteed to be UTF-8, but was ASCII-8BIT, so
      #       # tag it as such
      #       @repo_name = params[:repo_name].force_encoding 'UTF-8'
      #     end
      #
      #     def index
      #       @repositories = Repository.all
      #     end
      #   end
      #
      # The show action in the above controller would have all parameter values
      # encoded as ASCII-8BIT. This is useful in the case where an application
      # must handle data but encoding of the data is unknown, like file system data.
      def skip_parameter_encoding(action)
        default_parameter_encoding(action, Encoding::ASCII_8BIT)
      end

      # Specify that a given action's parameters should all be
      # encoded as the encoding of the second argument.
      #
      # For example, a controller would use it like this:
      #
      #   class SomeIncomingWebhookController < ActionController::Base
      #     default_parameter_encoding :call, Encoding::SHIFT_JIS
      #
      #     def call
      #       params.transform_values! {|param| param.encode(Encoding::UTF_8)}
      #       @record = SomeRecord.find_or_initialize_by(external_id: params[:id])
      #
      #       @record.update!(call_params)
      #     end
      #
      #     def call_params
      #       params.permit(:name_kanji, :name_pronunciation, :description, :some_attribute_includes_kanji)
      #     end
      #   end
      #
      # Sometime, rails application implements incoming webhook endpoint from external system.
      # This method is useful when the external system speaks non UTF-8 encoding.
      def default_parameter_encoding(action, encoding)
        @_parameter_encodings[action.to_s] = Hash.new { encoding }
      end

      # Specify the encoding for a parameter on an action.
      # If not specified the default is UTF-8.
      #
      # You can specify a binary (ASCII_8BIT) parameter with:
      #
      #   class RepositoryController < ActionController::Base
      #     # This specifies that file_path is not UTF-8 and is instead ASCII_8BIT
      #     param_encoding :show, :file_path, Encoding::ASCII_8BIT
      #
      #     def show
      #       @repo = Repository.find_by_filesystem_path params[:file_path]
      #
      #       # params[:repo_name] remains UTF-8 encoded
      #       @repo_name = params[:repo_name]
      #     end
      #
      #     def index
      #       @repositories = Repository.all
      #     end
      #   end
      #
      # The file_path parameter on the show action would be encoded as ASCII-8BIT,
      # but all other arguments will remain UTF-8 encoded.
      # This is useful in the case where an application must handle data
      # but encoding of the data is unknown, like file system data.
      def param_encoding(action, param, encoding)
        @_parameter_encodings[action.to_s][param.to_s] = encoding
      end
    end
  end
end
