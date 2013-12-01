
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



module.exports.create = (config) ->

    local = 

        title:   if config.title?   then config.title   else 'Untitled' 
        uuid:    if config.uuid?    then config.uuid    # else  v4()
        context: if config.context? then config.context else  {}
        secret:  if config.secret?  then config.secret  else ''


        status:
            value: 'pending'
            at: new Date



        connect: -> 

            return local.reconnect() if local.socket?

            local.socket = socket = new EngineIoClient.Socket config.connect.uri


            socket.on 'error', ->

                #
                # error before first connect enters reconnect loop
                #

                if local.status.value is 'pending' then local.reconnect 'connecting'



            socket.on 'open', -> 

                local.status.value = 'connected'
                local.status.at = new Date

                if local.connecting? 

                    clearInterval local.connecting
                    delete local.connecting

                if local.reconnecting? 

                    clearInterval local.reconnecting
                    delete local.reconnecting



            socket.on 'close', -> 

                return if local.status.value is 'denied'

                local.reconnect 'reconnecting'

 

        #
        # connect / reconnect intervals
        #

        connecting: undefined
        reconnecting: undefined

        reconnect: (type) -> 

            return unless type is 'connecting' or type is 'reconnecting'
            return if local[type]?


            local[type] = setInterval (->

                #
                # repeat attempt to connect
                #

            ), 1000