public class InactivePlayerDeletionSchedule implements Schedulable {
	public void execute(SchedulableContext SC) {
      List<Player__c> players = new List<Player__c>();
      players = [select CreatedDate, Status__c from Player__c where Status__c = 'Waiting for activation'];
        
      for (Player__c player : players) {
      	if (DateTime.now() > player.CreatedDate.addDays(1)) {
    			delete player;
            }
        }  
   }
}