public class PlayerLoginController {
    
    public Player__c player {
    	get {
        	if (player == null) {
        		player = new Player__c();
        		}
      		return player;
    	}
    	set;
  }
    
    public PageReference logIn() {
        List<Player__c> currentPlayer = new List<Player__c>();
        currentPlayer = [select id, Email__c, Password__c, Status__c from Player__c where Email__c = :player.Email__c];
        
        if (currentPlayer.size() != 0 && currentPlayer.get(0) != null) {
           if (currentPlayer.get(0).Status__c == 'Activated') {
                if (currentPlayer.get(0).Password__c == player.Password__c) {
                    Cookie cookieObj = new Cookie('playerCookie', currentPlayer.get(0).id, null, 10800, false);
                    ApexPages.currentPage().setCookies(new Cookie[]{cookieObj});
                    return Page.Home_Page;
                }
                else {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Wrong password entered'));
                    return null;
                }
            }
            else {
                String exMessage = 'You have not confirm you email. Plese check your email box to do so.';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, exMessage));
                return null;
            }
        }
        else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There is no user with such email'));
            return null;
        }
    }
}