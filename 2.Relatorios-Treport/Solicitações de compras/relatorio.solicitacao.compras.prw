#INCLUDE 'TOTVS.CH'
#INCLUDE 'TOPCONN.CH'

/*/{Protheus.doc} RELATORSC
Function principal relatorio de solicita��es de compras
@type function
@version  Protheus 23.10
@author Kayke
@since 09/04/2024
@return variant, return_description
/*/
User function RELATORSC()
    Local oReport := Nil As Object 
    local cAlias    := getNextAlias()           as Character
    Local cPergRel  := "RELATORIO SOLIC. COMPRAS" as Character

    oReport := scPrintRel(cAlias,cPergRel)
    oReport:PrintDialog()

return Nil 

/*/{Protheus.doc} scPrintRel
Fun��o para gerar relatorio
@author Kayke
@since 09/04/2024
/*/
static function scPrintRel()
    
    quer
	oSecCab:BeginQuery()
	oSecCab:EndQuery({{"QRY"},cQuery})
	oSecCab:Print()

return 
