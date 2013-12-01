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

                subject.does 

                    reconnect: (type) -> 

                        type.should.equal 'connecting'
                

                subject.connect()


        it 'sets status to connected on socket open', 

            ipso (subject, socket, EngineIOClient) ->

                EngineIOClient.Socket = class

                    on: (pub, sub) -> if pub is 'open' then sub()


                subject.status.value = 'pending'
                delete subject.socket

                subject.connect()
                subject.status.value.should.equal 'connected'


