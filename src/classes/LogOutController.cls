public class LogOutController {
	public PageReference logOut() {
        Cookie uselessCookie = new Cookie('playerCookie', '', null, 0, false);
        ApexPages.currentPage().setCookies(new Cookie[]{ uselessCookie });
        return Page.Home_Page;
    }
}