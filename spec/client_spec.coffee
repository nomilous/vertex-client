{ipso, mock, tag} = require 'ipso'

describe 'Client', ipso (should) -> 
    

    before ipso (Client) -> 

        tag 

            subject: Client mock('config').with

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


