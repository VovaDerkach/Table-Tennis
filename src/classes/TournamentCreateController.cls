public class TournamentCreateController extends AdminPermissions {
	public Tournaments__c tournament {
        get {
            if (tournament == null) {
                tournament = new Tournaments__c();
            }
            return tournament;
        }
        set;
    }
    
    public PageReference save() {
    	try {
        	upsert tournament;
    	} catch (DMLException e) {
      		ApexPages.addMessages(e);
      		return null;
    	}
        
    	return Page.TournamentCreate_thankYou;
	}
    
    public void edit() {
        String urlValue = Apexpages.currentPage().getUrl();
        String tournamentId = ApexPages.currentPage().getParameters().get('id');
        if (tournamentId != null) {
        List<Tournaments__c>  retrievedTournaments = new List<Tournaments__c>();
        retrievedTournaments = [Select id, Name__c, Type__c, Format__c, Status__c, Start_Date__c, Complete_Date__c 
             							from Tournaments__c where Id =:tournamentId];
            tournament = retrievedTournaments[0];
        } 
    }
    
    public Boolean showPage {
        get {
            String exMessage = 'You have not got enough permissions to browse this page.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, exMessage));
            return false;
        }
        set;
    }
    
    public Boolean showFormForAdmin {
        get {
        	if (isManager == true) {
            return true;
        	}
        else {
            String exMessage = 'You have not got enough permissions to browse this page.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, exMessage));
            return true;	
        	}
        }
        set;
    }
}