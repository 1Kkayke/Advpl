
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

Static lStackRpc := IsInCallStack("U_CRGSENDMAIL")

/*/{Protheus.doc} u_CRGSENDMAIL
Class para envio de Email      
@type function
@version  
@author Krebs 
@since 12/12/2023
@param cSubject, character, param_description
@param cBody, character, param_description
@param cTo, character, param_description
@param aCnx, array, param_description
@param aAnx, array, param_description
@return variant, return_description
/*/
Function u_CRGSENDMAIL(cSubject,cBody,cTo,aCnx,aAnx)
Local oMail := Nil
Local lSend := .F.

	PARAMTYPE 0 VAR cSubject AS CHARACTER
	PARAMTYPE 1 VAR cBody    AS CHARACTER
	PARAMTYPE 2 VAR cTo      AS CHARACTER
	PARAMTYPE 3 VAR aCnx     AS ARRAY
	PARAMTYPE 4 VAR aAnx     AS ARRAY OPTIONAL DEFAULT {}
	
	WFConout( "Inicio do processo de envio de Email!";
	          ,,,,.T.,"CRGSENDMAIL" )
	
	WFConout( "cSubject : " + cSubject,,,,.T.,"CRGSENDMAIL" )
	//WFConout( "cBody    : " + cBody   ,,,,.T.,"CRGSENDMAIL" )
	WFConout( "cTo      : " + cTo     ,,,,.T.,"CRGSENDMAIL" )

	oMail := CRGSendMail():New(aCnx)
	oMail:cTo      := cTo
	oMail:cSubject := cSubject
	oMail:cBody    := cBody
	oMail:aAttach  := aClone( aAnx )
	lSend := oMail:SendMail()

	WFConout( "Final do processo de envio de Email!";
	          ,,,,.T.,"CRGSENDMAIL" )

Return( lSend )


Class CRGSendMail From LongClassName

	Data cAccount		//% Usuario
	Data cPassword		//% Senha
	Data cSmtpServer	//% Servidor SMTP
	Data nSmtpP465		//% Porta SMTP
	Data nSmtpP587		//% Porta SMTP Secundaria
	Data cFrom			//% De usuario do eMail
	Data cTo			//% Lista de eMails
	Data cCC			//% Lista de eMails em Copia
	Data cBCC			//% Lista de eMails em Copia Oculta
	Data cSubject		//% Assunto
	Data cBody			//% Conteudo do eMail
	Data aAttach		//% Arquivos anexados
	Data nPriority		//% Prioridade => 1=Alta; 3=Normal; 5=Baixa
	Data aLog			//% Logs do envio
	Data lSend			//% Flag de envio: .T. = Enviado; .F. = Nao Enviado
	Data lMailAuth		//% Flag se exige Autenticacao
	Data lUseSSL		//% Utiliza SSL
	Data lUseTLS		//% Utiliza TLS
					
	Method New(aCnx) Constructor
	Method SendMail()
	Method InitSend() 
	Method AttachFile( cFile ) 
	Method ReadAttach(oMessage)
		
EndClass       

Method New(aCnx) Class CRGSendMail  
Local laCnx := ( !Empty( aCnx ) .And. Len(aCnx) == 9 )

	PARAMTYPE 0 VAR aCnx AS ARRAY OPTIONAL DEFAULT {}
	
	If lStackRpc .And. !laCnx
		WFConout( "Chamada Via RPC StartJob, e o vetor esta faltando elementos";
		          ,,,,.T.,"CRGSENDMAIL" )
		Break          
	EndIf
	
	::lMailAuth   := If( lStackRpc, aCnx[1] , SuperGetMv("MV_RELAUTH",,.F.) )//Servidor de EMAIL necessita de Autenticacao?
	::cSmtpServer := If( lStackRpc, aCnx[2] , SuperGetMv("MV_RELSERV",, "") )
	::cAccount    := If( lStackRpc, aCnx[3] , SuperGetMV("MV_RELACNT",, "") )
	::cPassword   := If( lStackRpc, aCnx[4] , SuperGetMV("MV_RELPSW" ,, "") )
	::lUseSSL	  := If( lStackRpc, aCnx[5] , SuperGetMV("MV_RELSSL" ,,.F.) )
	::lUseTLS	  := If( lStackRpc, aCnx[6] , SuperGetMV("MV_RELTLS" ,,.F.) )
	::cFrom		  := If( lStackRpc, aCnx[7] , SuperGetMV("MV_RELFROM",,"" ) )
	::nSmtpP465   := If( lStackRpc, aCnx[8] , SuperGetMV("J2A_PORT01",,465) )
	::nSmtpP587   := If( lStackRpc, aCnx[9] , SuperGetMV("J2A_PORT02",,587) )
    
	::cFrom       := ::cAccount
	::cTo         := ""
	::cCC         := ""
	::cBCC        := "" 
	::cSubject    := ""
	::cBody       := ""
	::aAttach     := {}
	::nPriority   := 3
	::aLog        := {}
	::lSend       := .F.

Return Self	


Method InitSend() Class CRGSendMail  

Local _nAttach		:= 0 	
Local _cFile		:= ""	
Local _oMessage

::aLog		:= {}          

For _nAttach := 1 To Len(::aAttach)
                                                                      
	If File( ::aAttach[_nAttach] )

		ItConOut("[Attach] File " + ::aAttach[_nAttach] + " Attached.", ::aLog)
         
		_cFile += iif(Empty(_cFile),"",",") +  ::aAttach[_nAttach]
		
	Else

		ItConOut("[Attach] Fail Try Attache.", ::aLog)
		ItConOut("[Attach] File not found " + ::aAttach[_nAttach] + ".", ::aLog)
	
	EndIf

Next

::cTo		:= Replace(::cTo,";",",")
While Space(01) $ ::cTo

	::cTo	:= Replace(::cTo,Space(01),"")

EndDo

::cBody 	:= Replace(::cBody,chr(10),"")
::cBody 	:= Replace(::cBody,chr(13),"")

Return


Method ReadAttach(oMessage) Class CRGSendMail  

Local _nAttach	:= 0 	
Local _nReturn	:= 0   
Local _cFile	:= ""	
Local _lAbort	:= .F. 

PARAMTYPE 0 VAR oMessage AS OBJECT

	::aLog		:= {}          
	
	For _nAttach := 1 To Len(::aAttach)
	                                                                      
		If File( ::aAttach[_nAttach] )
	
			ItConOut("[Attach] File " + ::aAttach[_nAttach] + " Attached.", ::aLog)
	         
			_nReturn := oMessage:AttachFile( ::aAttach[_nAttach] )
	
			If _nReturn < 0
				cMsg := "Could not attach file " + ::aAttach[_nAttach]
				ItConOut( cMsg , ::aLog)
				_lAbort	:= .T. 
			EndIf
			
		Else
	
			ItConOut("[Attach] Fail Try Attache.", ::aLog)
			ItConOut("[Attach] File not found " + ::aAttach[_nAttach] + ".", ::aLog)
		
		EndIf
	  	
	Next _nAttach

	If _lAbort
		ItConOut("[Attach] File Critical Error....Aborting send mail!!!", ::aLog)
	EndIf

Return

Method AttachFile( cFile 		;	//% Caminho e nome do arquivo a ser anexado
								 ) Class CRGSendMail  

	aAdd( ::aAttach, cFile )	// Adiciona o arquivo ao array do objeto

Return Nil

Static Function ItConOut( cTexto,;	//% Mensagem 
							aTexto ) //% Array do objeto

	ConOut( cTexto )		// Envia mensagem a console do Protheus
	aAdd(aTexto, cTexto)	// Adiciona mensagem ao array do objeto

Return Nil

Method SendMail() Class CRGSendMail  

Local oMail			:= NIL
Local nAt			:= 0
Local cServer		:= 0
Local nPort			:= 0
Local nErro			:= 0
Local cUsuario		:= Subs(Self:cAccount,1,At("@",Self:cAccount)-1)
Local oMessage		:= NIL
Local cMsgErro		:= ""

If (!Empty(::cSmtpServer)) .AND. (!Empty(::cAccount)) .AND. (!Empty(::cPassword))
	
	::InitSend()
	
	If lStackRpc
		WFConout( "Inicio do processo TMailManager!",,,,.T.,"ENVIO" )
	EndIf
	
	oMail	:= TMailManager():New()
	oMail:SetUseSSL(Self:lUseSSL)
	oMail:SetUseTLS(Self:lUseTLS)
	
	nAt	:=  At(':' , Self:cSmtpServer)
	
	// Para autenticacao, a porta deve ser enviada como parametro[nSmtpPort] na chamada do método oMail:Init().
	If ( nAt > 0 )
		cServer	:= Subs(Self:cSmtpServer , 1 , (nAt - 1) )
		nPort	:= Val(AllTrim(Subs(Self:cSmtpServer , (nAt + 1) , Len(Self:cSmtpServer) )) )
	Else
		cServer	:= Self:cSmtpServer
	EndIf
	
	If nPort == 0 .And. !Empty(::nSmtpP587)
		nPort := ::nSmtpP587
	EndIf
	
	//Init( < cMailServer >, < cSmtpServer >, < cAccount >, < cPassword >, [ nMailPort ], [ nSmtpPort ] )
	oMail:Init("", cServer, Self:cAccount, Self:cPassword , 0 , nPort)	
	oMail:SetSmtpTimeOut( 60 )
	nErro := oMail:SMTPConnect()

	If lStackRpc
		WFConout( "Conexao na Port :" + cValToChar(nPort) + " MSG " + oMail:GetErrorString(nErro) ;
		          ,,,,.T.,"ENVIO" )
	EndIf

	If ( nErro != 0 )
		oMail:SmtpDisconnect()
		oMail:Init( "", cServer, Self:cAccount, Self:cPassword , 110 , 25 )	
		oMail:SetSmtpTimeOut( 60 )
		nErro := oMail:SMTPConnect()
	EndIf

	If ( nErro != 0 )
		oMail:SmtpDisconnect()
		oMail:Init("", cServer, Self:cAccount, Self:cPassword , 0 , ::nSmtpP587)	
		oMail:SetSmtpTimeOut( 60 )
		nErro := oMail:SMTPConnect()
	EndIf

	If ( nErro != 0 )
		oMail:SmtpDisconnect()
		oMail:Init("", cServer, Self:cAccount, Self:cPassword , 0 , ::nSmtpP465)	
		oMail:SetSmtpTimeOut( 60 )
		nErro := oMail:SMTPConnect()
		If lStackRpc
			WFConout( "Conexao 2 na Port :" + cValToChar(::nSmtpP465) + " MSG " + oMail:GetErrorString(nErro) ;
			          ,,,,.T.,"ENVIO" )
		EndIf
	Endif
		
	If ( nErro == 0 )

		If lStackRpc
			WFConout( "Servidor de EMAIL necessita de Autenticacao? " +;
			cValToChar(Self:lMailAuth),,,,.T.,"ENVIO" )
		EndIf

		If Self:lMailAuth

			// try with account and pass
			nErro := oMail:SMTPAuth(Self:cAccount, Self:cPassword)
			If nErro != 0
				// try with user and pass
				nErro := oMail:SMTPAuth(cUsuario, Self:cPassword)
				If nErro != 0
					cMsgErro := oMail:GetErrorString(nErro)
					If lStackRpc
						WFConout( OemToAnsi("Falha na conexão com servidor de e-mail")+;
						CRLF + cMsgErro,,,,.T.,"ENVIO" )
					Else
						Aviso(OemToAnsi("Atenção"),OemToAnsi("Falha na conexão com servidor de e-mail") + CHR(13) + cMsgErro ,{"Ok"})
					EndIf
					Return Nil
				EndIf
			EndIf
		Endif
		
		oMessage := TMailMessage():New()
		
		//Limpa o objeto
		oMessage:Clear()

		//Popula com os dados de envio
		oMessage:cFrom 		:= Self:cFrom
		oMessage:cTo 		:= Self:cTo
		oMessage:cCc 		:= Self:cCC
		oMessage:cBcc 		:= Self:cBCC
		oMessage:cSubject 	:= Self:cSubject

		If !lStackRpc .And. SuperGetMV("J2A_HABANX",.F.,.F.)

			cMsg:="Segue em anexo o status da requisição "+"123456" //Adicionar numero
			cMsg+=" com a sua situação atual na base de dados da Empresa."
			cMsg+= CRLF
			cMsg+="Para garantir que nossos E-mails cheguem em sua caixa de entrada,"
			cMsg+="adicione o e-mail  ao seu catálogo de endereços."
			cMsg+= CRLF

			oMessage:cBody := cMsg

			::ReadAttach(oMessage)

		Else

			oMessage:cBody 		:= Self:cBody

		EndIf
		
		//If lStackRpc
		//	WFConout( "TMailMessage cBody : " + Self:cBody;
		//			  ,,,,.T.,"ENVIO" )
		//EndIf

		//Envia o e-mail
		nErro := oMessage:Send( oMail )
		
		If !(nErro == 0) 
			cMsgErro := oMail:GetErrorString(nErro)
			If lStackRpc
				WFConout( "Falha no envio do e-mail. Erro retornado: "+;
				oMail:GetErrorString(nErro),,,,.T.,"ENVIO" )
			Else
				Aviso(OemToAnsi("Atenção - Error Send") ,"Falha no envio do e-mail. Erro retornado: " + CHR(13) + cMsgErro,{"OK"})
			EndIf
		Else
			Self:lSend	:= .T.
		EndIf

		//Desconecta do servidor
		oMail:SmtpDisconnect()
		
	Else
	
		cMsgErro := oMail:GetErrorString(nErro)
		If lStackRpc
			WFConout( "Falha na conexão com servidor de e-mail"+;
			oMail:GetErrorString(nErro),,,,.T.,"ENVIO" )
		Else
			Aviso(OemToAnsi("Atenção"),OemToAnsi("Falha na conexão com servidor de e-mail") + CHR(13) + cMsgErro ,{"Ok"})
		EndIf

	EndIf
	
Else

	If ( Empty(::cSmtpServer) )
		Help(" ",1,"NOTSMTP")//"O SMTP Server nao foi configurado no paramtro MV_RELSERV!!!" ,"Atencao"
	EndIf

	If ( Empty(::cAccount) )
		Help(" ",1,"NOTACCOUNT")//"A Account do email nao foi configurado no parametro MV_RELACNT !!!" ,"Atencao"
	EndIf
	
	If Empty(::cPassword)
		Help(" ",1,"NOTPASSWORD")//"O Password do email nao foi configurado no parametro MV_RELPSW !!!" ,"Atencao"
	EndIf
	
EndIf

	If lStackRpc
		WFConout( "Final do processo TMailManager!",,,,.T.,"ENVIO" )
	EndIf

Return( Self:lSend )
