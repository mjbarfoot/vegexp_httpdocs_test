function ModalPopupsConfirm() {
    ModalPopups.Confirm("idConfirm1",
        "Please confirm you wish to accept cookies",
        "<div style='padding: 25px;'>Cookies are used <b>only</b> to improve the ordering experience. <br><br/>No third party cookies are used. <br/><br/><b>Confirm you wish to use accept use of cookies?</b></div>", 
        {
            yesButtonText: "Yes",
            noButtonText: "No",
            onYes: "ModalPopupsConfirmYes()",
            onNo: "ModalPopupsConfirmNo()"
        }
    );
}
function ModalPopupsConfirmYes() {
    var url = "/cfc/security/control.cfc?method=setCookieAcceptRemote&IsCookieOK=1";
	TAC.send(url, null);		
    ModalPopups.Close("idConfirm1");
}
function ModalPopupsConfirmNo() {
    var url = "/cfc/security/control.cfc?method=setCookieAcceptRemote&IsCookieOK=0";
	TAC.send(url, null);
    ModalPopups.Cancel("idConfirm1");
}