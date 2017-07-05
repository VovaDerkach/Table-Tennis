public abstract class AdminPermissions {
    
	public Boolean isLogged { 
        get {
        if (ApexPages.currentPage().getCookies().get('playerCookie') == null) {
            isLogged = false;
        }
        else {
            isLogged = true;
        }
        return isLogged;	
        } 
        set;	
    }
    
    public Boolean isManager {
        get {
            if (isLogged == true) {
            Cookie playerCookie = ApexPages.currentPage().getCookies().get('playerCookie');
            String playerId = playerCookie.getValue();
            List<Player__c> player = new List<Player__c>();
            player = [select id, Email__c, Is_manager__c from Player__c where id = :playerId];
            Boolean isManager = player[0].Is_manager__c;
                return isManager;  
            }
            else {
                return false;	
            }
        }
        set;
    }
}