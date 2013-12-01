#
# todo: logger
#

if typeof require.exists is 'function'

    #
    # using the existance of component require.exists function to 
    # determine if running browser-side or server-side,
    # 
    # because 'engine.io-client' does not use the same module name 
    # on the client side (?)
    #

    #
    # running client-side
    #

    EngineIoClient = require 'engine.io'


else 

    #
    # running server-side
    #

    EngineIoClient = require 'engine.io-client'



module.exports.create = (config = {}) ->

    if config.connect?

        config.connect.interval ||= 1000

    local = 

        title:   if config.title?   then config.title   else 'Untitled' 
        uuid:    if config.uuid?    then config.uuid    # else  v4()
        context: if config.context? then config.context else  {}
        secret:  if config.secret?  then config.secret  else ''


        status:
            value: 'pending'
            at: new Date



        connect: -> 

            console.log 'connect'


            return local.reconnect() if local.socket?

            local.socket = socket = new EngineIoClient.Socket config.connect.uri



            socket.on 'error', (err) ->

                console.log 'error', err

                #
                # error before first connect enters reconnect loop
                #

                if local.status.value is 'pending' then local.reconnect 'connecting'



            socket.on 'open', -> 

                console.log 'open'

                local.status.value = 'connected'
                local.status.at = new Date


                if local.connecting? 

                    clearInterval local.connecting
                    delete local.connecting

                if local.reconnecting? 

                    clearInterval local.reconnecting
                    delete local.reconnecting


                socket.send JSON.stringify

                    event:   'handshake'
                    data:
                        title:   local.title
                        uuid:    local.uuid
                        context: local.context
                        secret:  local.secret



            socket.on 'close', -> 

                console.log 'close'

                return if local.status.value is 'denied'

                local.reconnect 'reconnecting'

 

        #
        # connect / reconnect intervals
        #

        connecting: undefined
        reconnecting: undefined

        reconnect: (type) -> 

            return unless type is 'connecting' or type is 'reconnecting'
            return if config.connect.interval < 1000
            return if local[type]?

            local[type] = setInterval (->

                #
                # repeat attempt to connect
                #

                console.log type
                local.socket.open()

            ), config.connect.interval



