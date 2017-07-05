trigger NewPlayerEmailSend on Player__c (after insert) {
    for(Player__c player : Trigger.new) {
        SendingNotifications.sendEmailToConfirmRegistration(player.Id, player.Name, player.Email__c);
    }
}