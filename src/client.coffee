
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

    {Socket} = require 'engine.io'


else 

    #
    # running server-side
    #

    {Socket} = require 'engine.io-client'



module.exports.create = (config) ->


    console.log Socket

    local = 

        title:   if config.title?   then config.title   else 'Untitled' 
        uuid:    if config.uuid?    then config.uuid    # else  v4()
        context: if config.context? then config.context else  {}
        secret:  if config.secret?  then config.secret  else ''

