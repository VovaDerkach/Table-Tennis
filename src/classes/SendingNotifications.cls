public class SendingNotifications {
	public static void sendEmailToConfirmRegistration(Id player_id, String player_name, String player_email){
        Messaging.reserveSingleEmailCapacity(2);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        String[] toAddresses = new String[] { player_email }; 

        mail.setToAddresses(toAddresses);
        mail.setReplyTo('derkachvolody@gmail.com');
        mail.setSenderDisplayName('Submit your email address');

        mail.setBccSender(false);
        mail.setUseSignature(false);
        
        String linkToFollow = 'http://volandtennis-developer-edition.eu6.force.com/Player_create?code='+ player_Id +'>';
        String greeting = 'Hello, ' + player_name + '. You have registered for taking part in table tennis tournament.';
        String confirmation = ' To confirm your email please follow the <a href=' + linkToFollow + 'link.</a>';
        mail.setHtmlBody(greeting + confirmation);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static void sendEmailToConfirmScores(String playerId, String opponentEmail, String gameId, 
                                                String firstScore, String secondScore) {
        List<Game__c> games = [Select id, Tournament__r.Name__c, First_opponent__c, First_opponent_name__c, 
                                             Second_opponent__c, Second_opponent_name__c
                                                          FROM Game__c where Id =:gameId];
        Game__c currGame = games.get(0);
        String tourName = currGame.Tournament__r.Name__c;
        String senderPlayerName = playerId.equals(currGame.First_opponent__c) ? currGame.First_opponent_name__c 
            																	: currGame.Second_opponent_name__c;
        String recipientPlayerName = playerId.equals(currGame.First_opponent__c) ? currGame.Second_opponent_name__c 
            																	  : currGame.First_opponent_name__c;
       
        Messaging.reserveSingleEmailCapacity(2);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new String[] { opponentEmail };
            
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('derkachvolody@gmail.com');
        mail.setSenderDisplayName('Confirm scores entered by your opponent');
        
        mail.setBccSender(false);
        mail.setUseSignature(false);
        
        String linkToFollow = 'http://volandtennis-developer-edition.eu6.force.com/' + 
            					'SingleGame?code=' + gameId + '&id='+ playerId + '&fScore=' + firstScore + '&sScore=' + secondScore + '>';
        String greeting = 'Hello, ' + recipientPlayerName + '. Your table tennis game opponent ' + senderPlayerName
            				+ ' has entered the result scores of your joint game at ' + tourName + '.';
        String confirmation = ' To confirm this result scores please follow the <a href=' + linkToFollow + 'link</a>' 
        + ' and press "Confirm scores" button.';
                                                    
        mail.setHtmlBody(greeting + confirmation);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static void sendEmailForTeamConfirmation(String senderId, String recipientId, String tournamentId, String teamName) {
    	List<Player__c> players = [Select Email__c FROM Player__c where Id =:recipientId];
        Player__c recipientPlayer = players.get(0);
        
        String teammateEmail = recipientPlayer.Email__c;
        
        Messaging.reserveSingleEmailCapacity(2);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new String[] { teammateEmail };
            
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('derkachvolody@gmail.com');
        mail.setSenderDisplayName('Accept team creation');
        
        mail.setBccSender(false);
        mail.setUseSignature(false);
        
        String linkToFollow = 'http://volandtennis-developer-edition.eu6.force.com/' + 
            					'SingleTournament?code=' + tournamentId + '&tName='+ teamName + 
            						'&senId=' + senderId + '&recId=' + recipientId + '>';
        
        List<Player__c> recipients = [SELECT Name FROM Player__c WHERE Id = :recipientId];
        String recipientPlayerName = recipients.get(0).Name;
        
        List<Player__c> senders = [SELECT Name FROM Player__c WHERE Id = :senderId];
        String senderPlayerName = senders.get(0).Name;
        
        List<Tournaments__c> tournaments = [SELECT Name__c FROM Tournaments__c WHERE Id = :tournamentId];
        String tourName = tournaments.get(0).Name__c;
        
        String greeting = 'Hello, ' + recipientPlayerName + '. ' + senderPlayerName
            				+ ' wants to create a table tennis team with you at ' + tourName + ' tournament.';
        String confirmation = ' To confirm this creation please follow the <a href=' + linkToFollow + 'link</a>' 
        + ' and press "Save team" button.';
                                                    
        mail.setHtmlBody(greeting + confirmation);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}