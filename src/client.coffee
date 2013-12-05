


#
# require('debug').enable('vertex-client:*');
# DEBUG=vertex-client:* 
# 

debug = require('debug') 'vertex-client:base'

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


        peers: {}


        status:
            value: 'pending'
            at: new Date



        connect: -> 

            return local.reconnect() if local.socket?

            debug 'connecting to %s', config.connect.uri

            local.socket = socket = new EngineIoClient.Socket config.connect.uri





            socket.on 'error', (err) ->

                debug 'error %s', config.connect.uri, err

                #
                # error before first connect enters reconnect loop
                #

                if local.status.value is 'pending' then local.reconnect 'connecting'





            socket.on 'open', -> 

                debug 'opened %s', config.connect.uri

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

                debug 'closed %s', config.connect.uri

                return if local.status.value is 'denied'

                local.reconnect 'reconnecting'





            socket.on 'message', (payload) -> 

                #
                # protocol may need some de-bloating / optimization / later
                # ---------------------------------------------------------
                # 
                # * protocol selection/agreement should move into handshake
                # * is pure binary possible?
                #

                message = JSON.parse payload

                if typeof local[message.event] is 'function'

                    return local[message.event] message


                debug 'missing event handler for %s', [message.event]


                #
                # pending proper interface to socket
                # ----------------------------------
                # 
                # - EventEmitter



        deny: -> 
            
            local.status.value = 'denied'
            local.status.at = new Date
            debug 'denied'



        accept: -> 
            
            local.status.value = 'accepted'
            local.status.at = new Date
            debug 'accepted'


        peer: (message) -> 

            debug 'peer event %s from %s', message.action, message.title


            #
            # todo: emit event (per action)
            #

            if message.action is 'depart'

                #
                # ? perhaps keep, with status departed and timestamp
                # ? reap later
                #

                delete local.peers[ message.uuid ]
                return


            else if message.action is 'join'

                local.peers[ message.uuid ] = 

                    title: message.title
                    context: message.context


            else if message.action is 'resume'

                #
                # currently can also mean second connect from same uuid
                # pending decisions... (behaves exactly like join)
                # 

                local.peers[ message.uuid ] = 

                    title: message.title
                    context: message.context

 

        #
        # connect / reconnect intervals
        #

        connecting: undefined
        reconnecting: undefined

        reconnect: (type) -> 

            return unless type is 'connecting' or type is 'reconnecting'
            return if local[type]?

            interval = config.connect.interval
            interval = 1000 if interval < 1000

            local[type] = setInterval (->

                #
                # repeat attempt to connect
                #

                debug '%s to %s', type, config.connect.uri
                local.socket.open()

            ), interval



