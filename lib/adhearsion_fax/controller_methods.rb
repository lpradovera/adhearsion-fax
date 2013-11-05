module AdhearsionFax
  module ControllerMethods

    # Sends the specified faxes.
    #
    # @example Send a simple fax
    #   send_fax 'http://example.com/fax.tiff', identity: '+1404....', header: 'This is a fax for you', pages: 1..4
    # @example Send multiple faxes
    #   send_fax 'http://example.com/fax.tiff', 'http://example.com/fax2.tiff', pages: 1..4
    # @example Send different pages on different faxes, with a common header
    #   send_fax({'http://example.com/fax.tiff' => {pages: 1..2}, 'http://example.com/fax2.tiff' => {pages: 3..4}}), header: "Same"
    #
    # @raise [PlaybackError] if the given fax could not be sent
    #
    def send_fax(*arguments)
      options = process_fax_args arguments
      fax_player.output FaxFormatter.format_faxes(arguments, options)
      true
    end

    # @private
    def process_fax_args(arguments)
      arguments.last.is_a?(Hash) && arguments.count > 1 ? arguments.pop : {}
    end

    # @private
    def fax_player
      @fax_player ||= FaxPlayer.new(self)
    end

    #
    # Waits for a fax and returns it, or returns nil if nothing was received
    #
    # @return [ReceiveFax::Fax] The fax document, or nil if timeout was reached.
    #
    def receive_fax
      component = Punchblock::Component::ReceiveFax.new
      execute_component_and_await_completion component

      component.complete_event.fax
    end
  end
end
