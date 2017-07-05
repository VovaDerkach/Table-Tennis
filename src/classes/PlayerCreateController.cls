public class PlayerCreateController {
    
  public String confirmPassword {get; set;}
    
  public Player__c player {
    get {
        if (player == null) {
            player = new Player__c(); 
        }
      	return player;
    }
    set;
  }

  public PageReference save() {

    try {
        if (confirmPassword != player.Password__c) {
            DmlException dmlException = new DmlException();
            dmlException.setMessage('Passwords does not match');
            throw dmlException;
        }
        else {
        insert player;
            try {
        		String deletingSchedulePeriod = '0 0 6 * * ?';
        		InactivePlayerDeletionSchedule apxJob = new InactivePlayerDeletionSchedule();
        		system.schedule('Deletion of inactive users', deletingSchedulePeriod, apxJob);
            }
            catch (Exception e) {	}
        }
    } catch (DMLException e) {
      ApexPages.addMessages(e);
      return null;
    }

    return Page.Player_create_thank_You;
  }
    
    public PageReference check() {
        String urlValue = Apexpages.currentPage().getUrl();
        String passedId = ApexPages.currentPage().getParameters().get('code');
        List<Player__c>  neededUsers= [Select Id from Player__c where Id=:passedId];
        
        if (neededUsers != null && urlValue.contains('code')) {
            neededUsers[0].Status__c = 'Activated';
            
            Cookie cookieObj = new Cookie('playerCookie', passedId, null, 10800, false);
        	ApexPages.currentPage().setCookies(new Cookie[]{cookieObj});
            
            update neededUsers;
            return Page.Home_Page;
        }
        return null;
    }
}