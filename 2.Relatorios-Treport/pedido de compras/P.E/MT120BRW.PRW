
/*/{Protheus.doc} MT120BRW
P.E para adicionar botoes na rotina de pedido de compras - MATA120
@type function
@version  Protheus 23.10
@author Kayke
@since 28/03/2024
@return variant, return_description
/*/
User Function MT120BRW()
//Define Array contendo as Rotinas a executar do programa     
// ----------- Elementos contidos por dimensao ------------    
// 1. Nome a aparecer no cabecalho                             
// 2. Nome da Rotina associada                                 
// 3. Usado pela rotina                                        
// 4. Tipo de Transa‡„o a ser efetuada                         
//    1 - Pesquisa e Posiciona em um Banco de Dados            
//    2 - Simplesmente Mostra os Campos                        
//    3 - Inclui registros no Bancos de Dados                  
//    4 - Altera o registro corrente                           
//    5 - Remove o registro corrente do Banco de Dados         
//    6 - Altera determinados campos sem incluir novos Regs     
AAdd( aRotina, { 'Relatorio Treport', 'U_RELCOMP01', 0, 2 } )

Return 
