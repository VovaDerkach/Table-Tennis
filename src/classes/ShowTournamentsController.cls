public class ShowTournamentsController {
	public List<Tournaments__c> tournaments {
        get {
            if (tournaments == null) {
                tournaments = [select Name__c, Type__c, Format__c, Status__c, Start_Date__c, Complete_Date__c 
                               			from Tournaments__c];
            }
            return tournaments;
        }
        set;
    }
}