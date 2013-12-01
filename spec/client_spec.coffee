{ipso, mock, tag} = require 'ipso'

describe 'Client', ipso (should) -> 
    

    before ipso (Client) -> 

        tag 

            subject: Client.create mock('config').with

                title: 'Title'
                uuid: 'UUID'
                secret: 'secret'
                context: some: 'things'


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


