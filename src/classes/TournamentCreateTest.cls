@isTest
private class TournamentCreateTest {
    static testMethod void testTournamentSave() {
        TournamentCreateController tournamentController = new TournamentCreateController();
        Tournaments__c tournament = tournamentController.tournament;
        tournament.Name__c = 'TestTournament';
        
        Test.startTest();
        String resultPage = tournamentController.save().getUrl();
        Test.stopTest();
        
        List<tournaments__c> tournaments = [SELECT Name__c FROM Tournaments__c WHERE Name__c = : tournament.Name__c];
        System.assertEquals(tournament.Name__c, tournaments[0].Name__c);
        //System.assertEquals('/apex/TournamentCreate_thankYou', resultPage);    
    }
}