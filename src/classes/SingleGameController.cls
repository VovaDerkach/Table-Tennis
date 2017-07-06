public class SingleGameController {

  public Game__c game {
    get {
        if (game == null) {
            game = new Game__c();
            String urlValue = Apexpages.currentPage().getUrl();
        	String gameId = ApexPages.currentPage().getParameters().get('code');
        	List<Game__c> retrievedGames = [Select id, Tournament__r.Name__c, 
                                            First_opponent__c, First_opponent_name__c, 
                                            First_opponent_score__c, Second_opponent__c, 
                                            Second_opponent_name__c, Second_player_score__c 
                                            FROM Game__c where Id =:gameId];
            game = retrievedGames[0];
        }
      	return game;
    }
    set;
  }
    
  Tournaments__c tournament {
    get {
        if (tournament == null) {
            tournament = new Tournaments__c();
            String urlValue = Apexpages.currentPage().getUrl();
        	String tournamentId = ApexPages.currentPage().getParameters().get('tourId');
        	List<Tournaments__c>  retrievedTournaments = [Select id, Name__c, Type__c, Format__c, 
                                                          Status__c, Start_Date__c, Complete_Date__c 
                                                          FROM Tournaments__c where Id =:tournamentId];
            tournament = retrievedTournaments[0];
        }
      	return tournament;
    }
    set;
  }
    
    Boolean isSinglePlayerTournament = tournament.Format__c == '1x1';
    
    public Boolean isGameParticipant {
        get {
            Cookie playerCookie = ApexPages.currentPage().getCookies().get('playerCookie');
       		String loggedPlayerId = playerCookie.getValue();
            
            if (isSinglePlayerTournament) {
            	if (loggedPlayerId.equals(game.First_opponent__c) || loggedPlayerId.equals(game.Second_opponent__c)) {
                	return true;
            	}
            	else {
                	return false;
            	}
            }
            else {
                List<Player_Team__c> teamsOfPlayer = [SELECT id, Team__r.Id FROM Player_Team__c WHERE Player__r.id = : loggedPlayerId];
                String playerOfTeamId = teamsOfPlayer.get(0).Team__r.id;
                
                if (playerOfTeamId.equals(game.First_opponent__c) || playerOfTeamId.equals(game.Second_opponent__c)) {
                	return true;
            	}
            	else {
                	return false;
            	}
            }
        }
        set;
    }
    
  public Boolean isScoreConfirmation {
        get {
            if (isScoreConfirmation == null) {
                return false;
            }
            else {
                return isScoreConfirmation;
            }
        }
        set;
    }
    
    public void sendScoresToConfirm() {
       Cookie playerCookie = ApexPages.currentPage().getCookies().get('playerCookie');
       String loggedPlayerId = playerCookie.getValue();
        
       String gameId = game.id;
        
       String firstScore = String.valueOf(game.First_opponent_score__c);
       String secondScore = String.valueOf(game.Second_player_score__c);
        
       String opponentId = loggedPlayerId.equals(game.First_opponent__c) ? game.Second_opponent__c : game.First_opponent__c;
       List<Player__c> players = [SELECT Email__c FROM Player__c WHERE id = : opponentId];
       String opponentEmail = players.get(0).Email__c;
           
       SendingNotifications.sendEmailToConfirmScores(opponentId, opponentEmail, gameId, firstScore, secondScore);
        
       String infoMessage = 'You have successfully sent entered scores for confirmation.';
       ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, infoMessage));
    }
    
    public void checkForScores() {
        String urlValue = Apexpages.currentPage().getUrl();
        if (urlValue.contains('id')) {
        isScoreConfirmation = true;
        String playerId = ApexPages.currentPage().getParameters().get('id');
        Decimal firstScore = Decimal.valueOf(ApexPages.currentPage().getParameters().get('fScore'));
        Decimal secondScore = Decimal.valueOf(ApexPages.currentPage().getParameters().get('sScore'));
            
        Cookie cookieObj = new Cookie('playerCookie', playerId, null, 10800, false);
        ApexPages.currentPage().setCookies(new Cookie[]{cookieObj});
            
       	game.First_opponent_score__c = firstScore;
        game.Second_player_score__c = secondScore;
        }
    }
    
    public void  saveScores() {
        update  game;
        
        String infoMessage = 'You have successfully confirmed the scores.';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, infoMessage));
    }
    
    public PageReference sendMessageAboutDenial() {
        
        String infoMessage = 'You have denied saving the scores.';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, infoMessage));
        
        return Page.Home_page;
    }
}