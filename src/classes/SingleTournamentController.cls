public class SingleTournamentController extends AdminPermissions {
    
    public String teamName {get; set;}
    String loggedPlayerId = null;
    
    String player {get; set;}
        
    public String getPlayer() {
            return player;
        }
            
    public void setPlayer(String player) {
            this.player = player;
        }
    
    public List<SelectOption> getItems() {
            List<SelectOption> options = new List<SelectOption>();
        	List<Player__c> players = [SELECT id, Name FROM Player__c];
        for (Player__c pl : players) {
            options.add(new SelectOption(pl.id, pl.Name));
        }
            return options;
        }
    
    public List<Player__c> players {
        get {
            if (players == null) {
                return players = [SELECT Name FROM Player__c];
            }
            else {
                return players;
            }
        }
        set;
    }
    
    public Boolean isTeamConfirmation {
        get {
            if (isTeamConfirmation == null) {
                return false;
            }
            else {
                return isTeamConfirmation;
            }
        }
        set;
    }
	       
   public Tournaments__c tournament {
    get {
        if (tournament == null) {
            tournament = new Tournaments__c();
            String urlValue = Apexpages.currentPage().getUrl();
        	String tournamentId = ApexPages.currentPage().getParameters().get('code');
        	List<Tournaments__c>  retrievedTournaments = [Select id, Name__c, Type__c, Format__c, 
                                                          Status__c, Start_Date__c, Complete_Date__c 
                                                          FROM Tournaments__c where Id =:tournamentId];
            tournament = retrievedTournaments[0];
        }
      	return tournament;
    }
    set;
  }
    
   public Boolean isUpcomingTour {
       get {
           return tournament.Status__c == 'Upcoming';
        }
        set;
    }
    
    public Boolean isInProgressTour {
        get {
            return tournament.Status__c == 'In progress';
        }
    }
    
    public Boolean isSinglePlayerTournament {
        get {
            return tournament.Format__c == '1x1';
        }
        set;
    }
    
    public Boolean isApplied {
        get {
            if (isLogged) {
                
        		Cookie playerCookie = ApexPages.currentPage().getCookies().get('playerCookie');	
            
        		loggedPlayerId = playerCookie.getValue();
            	if (isSinglePlayerTournament) {
            		List<Player_Tournament__c> tournamentApplications = [SELECT id FROM Player_Tournament__c 
                                                     WHERE Player_Tournament__c.Tournament__r.id = : tournament.id 
                                                     AND Player_Tournament__c.Player__r.id = :loggedPlayerId];
     
                    return tournamentApplications.size() != 0; 
            	}
                else {
                    List<Team__c> teamAtTour = [SELECT id FROM Team__c WHERE Tournament__c = :tournament.id];
                    return teamAtTour.size() != 0;
                }
            }
            else {
                return false;
            }
        }
            
        set;
    }
        
    public Boolean pickTeammate {
        get {
            if (pickTeammate == null) {
                return false;
            }
            else {
                return pickTeammate;
            }
        }
        set;
    }
    
    public void finishTournament() {
        tournament.Status__c = 'Finished';
        update tournament;
        
        String infoMessage = 'You have successfully finished the tournament.';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, infoMessage));
    }

    public PageReference deleteTournament() {
        List<Player_Tournament__c> junctionObjs = [SELECT id 
                                                   FROM Player_Tournament__c 
                                                   WHERE Player_Tournament__c.Tournament__r.id = : tournament.id];
        delete junctionObjs;
		delete tournament;
        
    	return Page.AllTournaments;
  }
    
    public PageReference editTournament() {
        if (isUpcomingTour) {
        String tournamentId = tournament.id;
        PageReference link= Page.CreateTournament;
    	link.getParameters().put('id', tournamentId);
        return link;
        }
        else {
            return null;
        }
  }
    
    public Pagereference apply() {
        if (isSinglePlayerTournament) {
        try {
        List<Player_Tournament__c> appliedPlayers = [SELECT id FROM Player_Tournament__c 
                                                     WHERE Player_Tournament__c.Tournament__r.id = : tournament.id 
                                                     AND Player_Tournament__c.Player__r.id = :loggedPlayerId];
            if (appliedPlayers.size() != 0) {
                DmlException dmlException = new DmlException();
            	dmlException.setMessage('You have already been registered for this tournament.');
            	throw dmlException;
            }
        Player_Tournament__c junctionObj = new Player_Tournament__c();   
        junctionObj.Tournament__c = tournament.id;
        junctionObj.Player__c = loggedPlayerId;
        
        insert junctionObj;
        
        String infoMessage = 'You have been successfully registered for this tournament.';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, infoMessage));
        return null;
        } 
        catch (DMLException e) {
      		ApexPages.addMessages(e);
      		return null;
    		}
        }
        else {
            return null;
        }
    }
    
    public Pagereference createTeam() {
        pickTeammate = !pickTeammate;
        return null;
    }
    
    public Pagereference saveTeam() {  
        Team__c team = new Team__c();
        team.Name__c = teamName;
        team.Tournament__c = tournament.id;
        insert team;
        
        Cookie playerCookie = ApexPages.currentPage().getCookies().get('playerCookie');
        loggedPlayerId = playerCookie.getValue();
        
        Player_Team__c junctionObj1 = new Player_Team__c();
        junctionObj1.Team__c = team.id;
        junctionObj1.Player__c = loggedPlayerId;
        insert junctionObj1;
        
        Player_Team__c junctionObj2 = new Player_Team__c();
        junctionObj2.Player__c = player;
        junctionObj2.Team__c = team.id;
        insert junctionObj2;
        
        String infoMessage = 'You have successfully created the new team.';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, infoMessage));
        pickTeammate = !pickTeammate;
        
        return null; 
    }
    
    public Pagereference sendTeamInvitation() {
        
        String infoMessage = null;
        List<Player_Team__c> playersTeams = [Select id From Player_Team__c Where Player__r.id = :player];
        if (playersTeams.size() != 0) {
            infoMessage = 'Your desired teammate already is a member of another team at this tournament.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, infoMessage));
            pickTeammate = !pickTeammate;
            return null;
        }
        
        
        SendingNotifications.sendEmailForTeamConfirmation(loggedPlayerId, player, tournament.id, teamName);
        
        infoMessage = 'You have successfully sent the team invitation.';
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, infoMessage));
        pickTeammate = !pickTeammate;
        
        return null;
    }
    
    public void checkIfConfirmationTeam() {
        String urlValue = Apexpages.currentPage().getUrl();
        if (urlValue.contains('tName')) {
        isTeamConfirmation = true;
        String proposedTeamName = ApexPages.currentPage().getParameters().get('tName');
        String tournamentId = ApexPages.currentPage().getParameters().get('code');
        String currPlayerId = ApexPages.currentPage().getParameters().get('recId');
        String teammateId = ApexPages.currentPage().getParameters().get('senId');
            
        Cookie cookieObj = new Cookie('playerCookie', currPlayerId, null, 10800, false);
        ApexPages.currentPage().setCookies(new Cookie[]{cookieObj});
            
        teamName = proposedTeamName;
        player = teammateId;
        
        }
    }
    
    public PageReference startTournament() {
        if (tournament.Status__c != 'Upcoming') {
            return null;
        }
        
        List<Tournaments__c> tournaments = [Select Status__c From Tournaments__c Where Status__c = :'In progress'];
            if (tournaments.size() != 0) {
                String errorMessage = 'Only one tournament can be in progress at a time.';
        		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, errorMessage));
                return null;
            }
        
        tournament.Status__c = 'In progress';
        update tournament;
        
        if (tournament.Type__c == 'Round Robin') {
        	roundRobingGrid();  
        }
        else if (tournament.Type__c == 'Single Elimination') {
            singleEliminationGrid();
        }
        
        String infoMessage = 'You have successfully started the tournament.';
       	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, infoMessage));
        
        return null;
    }
    
    List<Player__c> playersOfTour = null;
            
    List<Team__c> teamsOfTour = null;
    
    public List<String> playersNames {
        get {
            if (playersNames == null) {
                if (isSinglePlayerTournament) {
                playersNames = new List<String>();
                playersOfTour = [SELECT id, Name 
                          			FROM Player__c WHERE id 
                          			IN (SELECT Player__c FROM Player_Tournament__c WHERE Tournament__c = :tournament.id)];
                
                for (Player__c pl : playersOfTour) {
                    playersNames.add(pl.Name);
                }
                    playersNames.sort(); }
                else {
                    playersNames = new List<String>();
                	teamsOfTour = [SELECT id, Name__c 
                          			FROM Team__c
                          			WHERE Tournament__c = :tournament.id];
                
                	for (Team__c pl : teamsOfTour) {
                    	playersNames.add(pl.Name__c);
                	}
                    playersNames.sort();
                }
            }
            return playersNames;
        }
        set;
    }
    
    Map<String, Integer> nameToIdx {
        get{
            if (nameToIdx == null) {
               nameToIdx = new Map<String, Integer>();
               List<String> pNames = new List<String>(playersNames);
               for (Integer i = 0; i < pNames.size(); i++) {
            		nameToIdx.put(pNames.get(i), i);
        		}
            }
            return nameToIdx;
        }
        set;
    }
    
    Integer getPlayerNameIdx(String pName) {  
        return nameToIdx.get(pName);
    }
    
    public Map<String, List<Integer>> resultRRMatrix {
        get {
            if (resultRRMatrix == null && !isUpcomingTour) {
                resultRRMatrix = new Map<String, List<Integer>>();
                List<String> pNames = new List<String>();
                pNames.addAll(playersNames);
               
        		for (Integer i = 0; i < pNames.size(); i++) {
                    String plName = pNames.get(i);
            		List<Integer> scores = new Integer[pNames.size()];
                    List<Game__c> gamesWithPlayer = [SELECT First_opponent_name__c, First_opponent_score__c,  
                                            		Second_opponent_name__c, Second_player_score__c 
                                            		FROM Game__c 
                                            		WHERE First_opponent_name__c =:plName OR Second_opponent_name__c =:plName];
                    
                    for (Integer j = 0; j < gamesWithPlayer.size(); j++) {
                        Game__c currGame = gamesWithPlayer.get(j);
                        Integer firstOpponentScore = currGame.First_opponent_score__c.intValue();
                        Integer secondOpponentScore = currGame.Second_player_score__c.intValue();
                        
                        Integer currPlayerScore = currGame.First_opponent_name__c != plName ? firstOpponentScore : secondOpponentScore;
                        String currOpponentName = currGame.First_opponent_name__c == plName 
                            															? currGame.Second_opponent_name__c 
                            															: currGame.First_opponent_name__c;
                        
                        Integer scoreIdx = getPlayerNameIdx(currOpponentName);
                        
                        scores.set(scoreIdx, currPlayerScore);                       
                    }
                 
                 scores.add(i, -1);
                 resultRRMatrix.put(plName, scores);
        		}
            }
            return resultRRMatrix;
        }
        set;
    }

    
    public List<Game__c> allGames {
        get {
            if (tournament.Status__c == 'In progress') {
                if (allGames == null) {
            	allGames = [SELECT First_opponent__c,First_opponent_name__c, Second_opponent__c,Second_opponent_name__c,
                            First_opponent_score__c, Second_player_score__c
                            FROM Game__c WHERE Tournament__c = :tournament.id];
                }
            }
            return allGames;
        }
        set;
    }
    
    public void roundRobingGrid() {
        if (tournament.Format__c == '1x1') {
            playersOfTour = [SELECT id, Name 
                          			FROM Player__c WHERE id 
                          			IN (SELECT Player__c FROM Player_Tournament__c WHERE Tournament__c = :tournament.id)];
            
            createRRGrid(playersOfTour);  
        }
        else if (tournament.Format__c == '2x2') {
            teamsOfTour = [SELECT id, Name__c 
                			FROM Team__c WHERE Tournament__c = : tournament.id];
            
            createRRGrid(teamsOfTour);
        }
    }
    
    public void singleEliminationGrid() {
        if (tournament.Format__c == '1x1') {
            playersOfTour = [SELECT id, Name 
                          			FROM Player__c WHERE id 
                          			IN (SELECT Player__c FROM Player_Tournament__c WHERE Tournament__c = :tournament.id)];
            
           createSEGrid(playersOfTour); 
        }
        else if (tournament.Format__c == '2x2') {
            teamsOfTour = [SELECT id, Name__c 
                			FROM Team__c WHERE Tournament__c = : tournament.id];
            
            createSEGrid(teamsOfTour);
        }
    }
    
    public void createRRGrid(List<sObject> opponents) {
        List<Game__c> resultGames = new List<Game__c>();
        
        Integer opponentsCount = opponents.size();
        
        for (Integer i = 0; i < opponentsCount; i++) {
            
            for (Integer j = opponentsCount - 1; j > i; j--) {
                if (opponents.get(0) instanceof Player__c) {
                Player__c firstOpponent = (Player__c) opponents.get(i);
            	Player__c secondOpponent = (Player__c) opponents.get(j);
                    
                resultGames.add(new Game__c(Tournament__c = tournament.id, 
                                        First_opponent__c = firstOpponent.id, Second_opponent__c = secondOpponent.id,
                                       First_opponent_name__c = firstOpponent.Name, Second_opponent_name__c = secondOpponent.Name));
                }
                else {
                    Team__c firstOpponent = (Team__c) opponents.get(i);
            		Team__c secondOpponent = (Team__c) opponents.get(j);
                    
                	resultGames.add(new Game__c(Tournament__c = tournament.id, 
                                        First_opponent__c = firstOpponent.id, Second_opponent__c = secondOpponent.id,
                                       First_opponent_name__c = firstOpponent.Name__c, Second_opponent_name__c = secondOpponent.Name__c));
                }
            }
        }
        insert resultGames;          
    }
    
    public void createSEGrid(List<sObject> contenders) {
        List<Game__c> resultGames = new List<Game__c>();
        
        Integer contendersCount = contenders.size();
        
        
    }
}