{ipso, mock, tag} = require 'ipso'

describe 'Client', ipso (should) -> 
    

    before ipso (Client) -> 

        mock('socket').with

            on: ->
            open: ->
            send: ->


        tag 

            subject: Client.create mock('config').with

                title: 'Title'
                uuid: 'UUID'
                secret: 'secret'
                context: some: 'things'
                connect: 
                    uri: 'ws://localhost:3001'
                    interval: 1000


            EngineIOClient: require 'engine.io-client'


    it 'defines title, uuid, context, secret from config', ipso (subject) -> 

        subject.title.should.equal 'Title'
        subject.uuid.should.equal 'UUID'
        subject.context.should.eql some: 'things'
        subject.secret.should.equal 'secret'


    it 'does not expose secret'


    it 'creates a logger'


    it 'defines status', 

        ipso (subject) -> 

            subject.status.value.should.equal 'pending'
            subject.status.at.should.be.an.instanceof Date


    context 'connect()', ->

        it 'is defined', 

            ipso (subject) -> 

                subject.connect.should.be.an.instanceof Function


        it 'calls reconnect() if socket was already connected',

            ipso (subject) -> 

                subject.socket = {} # already has socket defined
                subject.does reconnect: -> 
                subject.connect()


        it 'creates the socket', 

            ipso (subject, socket, EngineIOClient) ->

                delete subject.socket # socket has not been connected

                EngineIOClient.Socket = class

                    constructor: (uri) -> 

                        uri.should.equal 'ws://localhost:3001'

                    on: ->


                subject.connect()



        it 'enters reconnect loop as "connecting" on socket error if status is pending', 

            ipso (subject, socket, EngineIOClient) ->

                EngineIOClient.Socket = class

                    on: (pub, sub) -> if pub is 'error' then sub()

                subject.status.value = 'pending'
                delete subject.socket

                subject.does _reconnect: (type) -> type.should.equal 'connecting'
                subject.connect()
                should.exist subject.connecting


        it 'sets status to connected, clears connection intervals and sends the handshake on socket open', 

            ipso (subject, socket, EngineIOClient) ->

                EngineIOClient.Socket = class

                    on: (pub, sub) -> if pub is 'open' then sub()
                    send: (payload) ->

                        JSON.parse( payload ).should.eql

                            event: 'handshake'
                            data: 
                                title: 'Title'
                                uuid:  'UUID'
                                context: 
                                    some: 'things'
                                secret: 'secret'


                subject.connecting = setInterval ->
                subject.reconnecting = setInterval ->
                subject.status.value = 'pending'
                delete subject.socket

                subject.connect()
                subject.status.value.should.equal 'connected'
                should.not.exist subject.connecting
                should.not.exist subject.reconnecting


        it 'sends deny event to sets status',


            ipso (subject, socket, EngineIOClient) -> 

                EngineIOClient.Socket = class

                    on: (pub, sub) -> 

                        if pub is 'message' 

                            sub JSON.stringify event: 'deny'


                delete subject.socket

                subject.does _deny: ->

                subject.connect()
                subject.status.value.should.equal 'denied'


        it 'sends accept event to updates status',


            ipso (subject, socket, EngineIOClient) -> 

                EngineIOClient.Socket = class

                    on: (pub, sub) -> 

                        if pub is 'message' 

                            sub JSON.stringify event: 'accept'


                delete subject.socket

                subject.does _accept: ->

                subject.connect()
                subject.status.value.should.equal 'accepted'




        it 'enters reconnect loop as "reconnecting" on socket close', 


            ipso (subject, socket, EngineIOClient) ->

                EngineIOClient.Socket = class

                    on: (pub, sub) -> 

                        if pub is 'open' then sub()
                        if pub is 'close' then sub()

                    send: ->

                subject.status.value = 'pending'
                delete subject.socket

                subject.does _reconnect: (type) -> type.should.equal 'reconnecting'
                subject.connect()
                should.exist subject.reconnecting



        it 'does not enter reconnect loop as "reconnecting" on socket close if status is denied',

            ipso (subject, socket, EngineIOClient, assert) ->

                EngineIOClient.Socket = class

                    on: (pub, sub) -> 

                        if pub is 'open' 

                            sub()
                            subject.status.value = 'denied'

                        if pub is 'close' then sub()

                    send: ->


                delete subject.socket
                clearInterval subject.connecting
                delete subject.connecting
                clearInterval subject.reconnecting
                delete subject.reconnecting

                subject.connect()
                should.not.exist subject.reconnecting


                

    context 'reconnect()', -> 


        it 'does not enter the reconnect loop if type isnt connecting or reconnecting', 

            ipso (subject) -> 

                delete subject.socket
                clearInterval subject.connecting
                delete subject.connecting
                clearInterval subject.reconnecting

                subject.reconnect 'reconnectType'
                should.not.exist subject.reconnectType



        it 'does not restart an already running reconnect loop', 

            ipso (subject) -> 


                delete subject.socket
                clearInterval subject.connecting
                delete subject.connecting
                clearInterval subject.reconnecting

                subject.reconnect 'connecting'
                interval = subject.connecting

                subject.reconnect 'connecting'
                subject.connecting.should.equal interval



        it 'calls open() on the socket at specified interval', 

            ipso (facto, subject) -> 

                now = Date.now()
                subject.socket = open: -> 

                                        # scheduler's a tad various
                    (Date.now() - now + 50 > 1000).should.equal true
                    clearInterval subject.connecting
                    facto()

                subject.reconnect 'connecting'



        it 'increases connect.interval to minimum 1000 ms', 

            ipso (Client) -> 

                instance = Client.create 
                    connect:
                        uri: 'ws://localhost:3001'
                        interval: 999

                instance.reconnect 'connecting'
                instance.connecting._idleTimeout.should.equal 1000



    it 'maintains a list of peers on the hub', ipso (subject) -> 

        subject.peers.should.eql {}


    context 'peer()', ->


        it 'adds peers to the collection', ipso (subject) -> 


            subject.peer

                action: 'add'
                title:  'Title'
                uuid:   'UUID'
                context:
                    some: 'thing'
                    other: 'stuff'


            subject.peers.should.eql 

                UUID: 

                    title:  'Title'
                    context:
                        some: 'thing'
                        other: 'stuff'





