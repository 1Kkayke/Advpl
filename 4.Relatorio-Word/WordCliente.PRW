#INCLUDE 'TOTVS.CH'
#INCLUDE 'MSOLE.CH'

#Define oleWdFormatDocument "0"
#Define oleWdFormatHTML "102"
#Define oleWdFormatPDF "17"

/*/{Protheus.doc} criarWord
 Relatorio de clientes gerado em word 
@type function
@version  protheus 23.10
@author Kayke Laurindo
@since 12/12/2023
@return variant, return_description
/*/
User function criarWord()

	Local cTitulo := "Impressão dos clientes em Word"

	If !perguntaDiretorio()
		FWAlertError("Impressão cancelada.","TOTVS")
		Return
	EndIf

	FWMsgRun(, {||imprimeWord() }, cTitulo, "Gerando o documento")

Return

static function imprimeWord()
	Local oWord
	Local cCaminho := Alltrim(MV_PAR01)
	local nQuant   := 0
	local x        := 0

	IF CpyS2T("Dot\doc1.dotm",cCaminho )

		oWord := OLE_CreateLink( "TMsOleWord97" )
		OLE_SetProperty( oWord, oleWdVisible, .F. )
		OLE_SetProperty( oWord, oleWdPrintBack, .F. )

		OLE_NewFile(oWord,cCaminho +"doc1.dotm")

		IF SELECT("QRY_SA1") > 0
			QRY_SA1->( DbCloseArea())
		ENDIF

		BeginSql Alias "QRY_SA1"
				SELECT *
				FROM %table:SA1% SA1
				WHERE SA1.%notDel%
		EndSql

		QRY_SA1->(DBGoTop())

		While !QRY_SA1->(Eof())
			nQuant := nQuant + 1
			QRY_SA1->(DBSkip())
		enddo

		OLE_SetDocumentVar(oWord, "Clientes_Qtd", nQuant)

		QRY_SA1->(DBGoTop())

		While !QRY_SA1->(Eof())
			for x = 1 To nQuant
				OLE_SetDocumentVar(oWord, "w_A1_COD"+Alltrim(Str(x)),    SA1->A1_COD)
				OLE_SetDocumentVar(oWord, "w_A1_NOME"+Alltrim(Str(x)),   SA1->A1_NOME)
				OLE_SetDocumentVar(oWord, "w_A1_LOJA"+Alltrim(Str(x)),   SA1->A1_LOJA)
				OLE_SetDocumentVar(oWord, "w_A1_TIPO"+Alltrim(Str(x)),   SA1->A1_TIPO)
				OLE_SetDocumentVar(oWord, "w_A1_ESTADO"+Alltrim(Str(x)), SA1->A1_ESTADO)
				OLE_SetDocumentVar(oWord, "w_A1_MUN"+Alltrim(Str(x)),    SA1->A1_MUN)
				OLE_SetDocumentVar(oWord, "w_A1_END"+Alltrim(Str(x)),    SA1->A1_END)
			Next
			QRY_SA1->(DBSkip())
		enddo

		OLE_ExecuteMacro(oWord,"macro")

		OLE_UpdateFields(oWord)

		if MV_PAR02 == "1"
			OLE_SaveAsFile( oWord, cCaminho +"doc1.docx")
		else
			OLE_SaveAsFile( oWord, cCaminho + "doc1.pdf", '', '', .F., oleWdFormatPDF)
		endif
		// Fecha o documento.
		OLE_CloseFile(oWord)

		//Fechando o arquivo e o link
		OLE_CloseLink(oWord)

		// // SE FOR WORD, ABRE O ARQUIVO
		if MV_PAR02 == "1"
			ShellExecute("open","doc1.docx","",cCaminho,1)
		else
			ShellExecute("open","doc1.pdf","",cCaminho,1)
		endif

	Else
		FWAlertError("Arquivo nao copiado","TOTVS")
	EndIf

return

static function perguntaDiretorio()
	Local aPergs := {}
	local lRet   := .F.

	aAdd(aPergs, {6, "Dir. Salvar", Space(90), "", , "", 90, .T., "Diretórios", "C:\", GETF_LOCALHARD+GETF_RETDIRECTORY})
	aAdd(aPergs, {2, "Tipo Arquivo", "1", {"1=Word", "2=PDF"}, 90, ".T.", .T.})

	If ParamBox(aPergs, "",,,,,,,,, .F., .F.)
		lRet := .T.
	EndIf

Return lRet
