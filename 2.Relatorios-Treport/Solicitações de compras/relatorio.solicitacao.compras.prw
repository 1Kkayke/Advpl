#INCLUDE 'TOTVS.CH'
#INCLUDE 'TOPCONN.CH'

/*/{Protheus.doc} RELATORSC
Function principal relatorio de solicitações de compras
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
Função para gerar relatorio
@author Kayke
@since 09/04/2024
/*/
static function scPrintRel()
    Local cQuery := ' ' as Character

    GeraQuery(cQuery)
    
    If Select("QRY") > 0
		Dbselectarea("QRY")
		SC1->(DbCloseArea())
	EndIF
	
    TcQuery cQuery New Alias "QRY"


    oSecCab:BeginQuery()
	oSecCab:EndQuery({{"QRY"},cQuery})
	oSecCab:Print()

return 

/*/{Protheus.doc} GeraQuery
Function responsavel pela query 
@author Kayke
@since 09/04/2024
/*/
static function GeraQuery(cQuery)

cQuery := " SELECT C1_FILIAL,C1_NUM,C1_ITEM,C1_PRODUTO,"
cQuery += " C1_UM,C1_DESCRI,C1_QUANT,C1_PRECO,C1_TOTAL,	"
cQuery += " C1_SEGUM,C1_LOCAL,C1_CC"
cQuery += " FROM "+RetSqlName("SC1") + " SC1"
cQuery := ChangeQuery(cQuery)


return cQuery
