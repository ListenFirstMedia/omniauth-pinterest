require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Pinterest < OmniAuth::Strategies::OAuth2
      option :client_options, {
        site: 'https://www.pinterest.com/',
        authorize_url: 'https://www.pinterest.com/oauth/',
        token_url: 'https://api.pinterest.com/v5/oauth/token',
        auth_scheme: :basic_auth
      }

      def request_phase
        options[:scope] ||= 'read_public'
        options[:response_type] ||= 'code'
        super
      end

      uid { raw_info['id'] }

      info { raw_info }

      def authorize_params
        super.tap do |params|
          %w[redirect_uri].each do |v|
            params[:redirect_uri] = request.params[v] if request.params[v]
          end
        end
      end

      def raw_info
        @raw_info ||= access_token.get('/v5/user_account/').parsed
      end

      def ssl?
        true
      end

      def build_access_token(*args)
        t = super(*args)
        t.client.site = 'https://api.pinterest.com/'
        t
      end

    end
  end
end
