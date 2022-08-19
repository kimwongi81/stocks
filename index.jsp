<%@ page contentType="text/html; charset=utf-8" %>

<%@ page import="org.jsoup.Jsoup" %>
<%@ page import="org.jsoup.nodes.Document" %>
<%@ page import="org.jsoup.select.Elements" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>

<style>
  table {
    width: 100%;
    border: 1px solid #444444;
    border-collapse: collapse;
    margin-top: 20px;
  }
  th, td {
    border: 1px solid #444444;
    padding: 10px;
  }
</style>

<script type="text/javascript" src="/js/jquery-2.2.0.min.js"></script>
<script type="text/javascript" src="/js/jquery-latest.js"></script>
<script type="text/javascript" src="/js/jquery.tablesorter.js"></script>

<%
	String number = request.getParameter("no");
	String theme = request.getParameter("type");
	String themeNm = request.getParameter("themeNm");
	String url = "";
	
	if("theme".equals(theme)){	//테마
		url = "https://finance.naver.com/sise/sise_group_detail.nhn?type=theme&no=" + number;
	}else{	//업종 
		url = "https://finance.naver.com/sise/sise_group_detail.nhn?type=upjong&no=" + number;
	}

	Document doc = Jsoup.connect(url).get();
	Elements elm = doc.select("div[class=name_area] a[href]");
	
	//종목 링크 구하기.
	String[] itmLinkList = new String[elm.size()];
	for(int i=0; elm.size() > i; i++ ){
		itmLinkList[i] = elm.get(i).attr("href");
	}


%>
<a href="javascript:history.back(-1);">뒤로</a>
<%=themeNm %> 
<input type="text" name="mt" id="mt" value="10" onKeypress="javascript:if(event.keyCode==13) {setMt()}">
<input type="button" name="mtSet" id="mtSet" value="멀티플" onClick="setMt();">
<input type="button" name="showMt" id="showMt" value="%보기" onClick="showMt();">
<input type="button" name="allShowMt" id="allShowMt" value="전체보기" onClick="allShowMt();">
<table id="table" class="tablesorter">
	<thead>
	<tr class="show">
		<th style="width: 400px;">종목명</th>
		<th style="width: 200px;">시가총액</th>
		<th style="width: 200px;">영업이익</th>
		<th style="width: 200px;">현재주가</th>
		<th style="width: 200px;">적정주가</th>
		<th style="width: 200px;">3년평균ROE</th>
		<th style="width: 200px;">3년평균ROE * 영업이익</th>
		<th style="width: 200px;">수치</th>
	</tr>
	</thead>
	<tbody>
<%	
	for(int i=0; itmLinkList.length > i; i++ ){
		
		//종목별 데이터 구하기.
		String url2 = "https://finance.naver.com/"+itmLinkList[i];
		Document doc2 = Jsoup.connect(url2).get();
		String companyName = doc2.select("div[class=wrap_company] a[href]").text();	//종목명
		String marketGb = doc2.select("div[class=description] img").attr("alt");	//시장 구분
		System.out.println("종목명 : " + companyName);
		
		String[] marketSums = doc2.select("div[class=tab_con1] em").eq(0).text().split("조");
		String stcQt = doc2.select("div[class=tab_con1] em").eq(2).text().replaceAll(",", "");	//주식수
		String[] price = doc2.select("p[class=no_today] em").eq(0).text().split(" ");	//현재주가
		
		System.out.println("price : " + price[0]);
		
		Double marketSum = 0.0;
		
		if(marketSums.length == 2){
			marketSums[1] = marketSums[1].replaceAll(",", "").replaceAll(" ", "");
			if(Integer.parseInt(marketSums[1]) <= 9){
				marketSums[1] = "000"+marketSums[1];
			}else if(Integer.parseInt(marketSums[1]) <= 99){
				marketSums[1] = "00"+marketSums[1];
			}else if(Integer.parseInt(marketSums[1]) <= 999){
				marketSums[1] = "0"+marketSums[1];
			}
			marketSum = Double.parseDouble(StringUtils.defaultIfEmpty((marketSums[0].replaceAll(" ", "")+marketSums[1].replaceAll(" ", "")).replaceAll(",", ""),"0"));	//시가총액
		}else{
			marketSum = Double.parseDouble(StringUtils.defaultIfEmpty(marketSums[0].replaceAll(",", "").replaceAll(" ", ""),"0"));	//시가총액
		}
		System.out.println("시가총액 : " + marketSum);
		
		//분기 영업이익
		String strQuarter0 = StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(16).text().replaceAll(",", "").replaceAll(" ", ""),"0");
		if("-".equals(strQuarter0)){
			strQuarter0 = "0";
		}
		String strQuarter1 = StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(17).text().replaceAll(",", "").replaceAll(" ", ""),"0");
		if("-".equals(strQuarter1)){
			strQuarter1 = "0";
		}
		String strQuarter2 = StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(18).text().replaceAll(",", "").replaceAll(" ", ""),"0");
		if("-".equals(strQuarter2)){
			strQuarter2 = "0";
		}
		String strQuarter3 = StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(19).text().replaceAll(",", "").replaceAll(" ", ""),"0");
		if("-".equals(strQuarter3)){
			strQuarter3 = "0";
		}
		Double quarter0 = Double.parseDouble(strQuarter0);	//영업이익 분기
		Double quarter1 = Double.parseDouble(strQuarter1);	//영업이익 분기
		Double quarter2 = Double.parseDouble(strQuarter2);	//영업이익 분기
		Double quarter3 = Double.parseDouble(strQuarter3);	//영업이익 분기
		if(quarter3 == 0){
			quarter3 = (quarter1+quarter2)/2;
		}
		
		//연도별 영업이익
		//Long profitLastYear = Double.parseDouble(StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(12).text().replaceAll(",", "").replaceAll(" ", ""),"0"));	//영업이익 작년
		String profitYear1 = doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(13).text().replaceAll(",", "").replaceAll(" ", "");	//영업이익 당해
		if("-".equals(profitYear1)){
			profitYear1 = "0";
		}
		Double profitYear2 = Double.parseDouble(StringUtils.defaultIfEmpty(profitYear1,"0"));	//영업이익 당해
		if(profitYear2 == 0){
			profitYear2 = quarter0 + quarter1 + quarter2 + quarter3;
		}
		
		//ROE 연간
		String strRoeYear1 = doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(51).text().replaceAll(",", "").replaceAll(" ", "");
		if("-".equals(strRoeYear1)){
			strRoeYear1 = "0";
		}
		Double roeYear1 = Double.parseDouble(StringUtils.defaultIfEmpty(strRoeYear1,"0"));	//영업이익 작년
		
		String strRoeYear2 = doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(52).text().replaceAll(",", "").replaceAll(" ", "");
		if("-".equals(strRoeYear2)){
			strRoeYear2 = "0";
		}
		Double roeYear2 = Double.parseDouble(StringUtils.defaultIfEmpty(strRoeYear2,"0"));	//영업이익 작년
		
		String strRoeYear3 = doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(53).text().replaceAll(",", "").replaceAll(" ", "");
		if("-".equals(strRoeYear3)){
			strRoeYear3 = "0";
		}
		Double roeYear3 = Double.parseDouble(StringUtils.defaultIfEmpty(strRoeYear3,"0"));	//영업이익 작년
		
		//ROE 분기
		Double roeQuarter1 = Double.parseDouble(StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(57).text().replaceAll(",", "").replaceAll(" ", "").replaceAll("-", ""),"0"));	//영업이익 작년
		if("-".equals(roeQuarter1)){
			roeQuarter1 = 0.0;
		}
		System.out.println("roeQuarter2 : " + doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(58).text());
		String strRoeQuarter2 = doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(58).text();
		Double roeQuarter2 = 0.0;	//영업이익 작년
		if("-".equals(strRoeQuarter2)){
			roeQuarter2 = 0.0;
		}else{
			roeQuarter2 = Double.parseDouble(StringUtils.defaultIfEmpty(strRoeQuarter2.replaceAll(",", "").replaceAll(" ", ""),"0"));	//영업이익 작년
		}
		Double roeQuarter3 = Double.parseDouble(StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(59).text().replaceAll(",", "").replaceAll(" ", ""),"0"));	//영업이익 작년
		if("-".equals(roeQuarter3)){
			roeQuarter3 = 0.0;
		}
		if(roeYear3 == 0){
			roeYear3 = (roeQuarter1 + roeQuarter2 + ((roeQuarter1 + roeQuarter2)/2))/3;
		}
		
		//연간 ROE 평균
		Double roeAvg = (roeYear1 + roeYear2 + roeYear3)/3;
		
		//영업이익 * ROE 3년평균 
		Double t = (profitYear2 * roeAvg);
		Double t2 = (profitYear2 * roeAvg)/marketSum;
		Double py = profitYear2 * 10;
		Double py1 = (profitYear2 * 1000000000) / Double.parseDouble(stcQt);
		Double py2 = (profitYear2 * 2000000000) / Double.parseDouble(stcQt);
		
%>
			<tr>
				<td><a href="<%=url2%>" target="_blank"><%=companyName %> (<%=marketGb %>)</a></td>
				<td>
<%
					if(py > marketSum){
%>
					<font color='#03c75a'><%=String.format("%,.0f", marketSum) %></font>
<%					
					}else{
%>
						<%=String.format("%,.0f", marketSum) %>
<%						
					}
%>
				</td>
<%
		if(profitYear2 < 0 && roeAvg < 0){	//마이너스일 경우
%>
				<td>0</td>
				<td>0</td>
				<td id="mt<%=i%>">0</td>
				<td>0</td>
				<td>0</td>
				<td>0</td>
<%				
		}else{
%>			
				<td class="py" id="<%=i%>" stcQt="<%=stcQt%>" price="<%=price[0] %>"><%=String.format("%.0f", profitYear2) %></td>
				<td><%=price[0] %></td>
				<td id="mt<%=i%>"></td>
				<td><%=String.format("%.2f", roeAvg) %></td>
				<td><%=String.format("%.2f", t) %></td>
				<td><%=String.format("%.2f", t2) %></td>
<%} %>				
			</tr>
<%		
	}

%>
	</tbody>
</table>
<%
	
	/*
	String url2 = "https://finance.naver.com/item/main.nhn?code=243070";
	Document doc2 = Jsoup.connect(url2).get();
	String companyName = doc2.select("div[class=wrap_company] a[href]").text();	//종목명
	Long marketSum = Double.parseDouble(doc2.select("div[class=first] em#_market_sum").text().replaceAll(",", "").replaceAll(" ", ""));	//시가총액
	
	//분기 영업이익
	Long quarter1 = Double.parseDouble(StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(17).text().replaceAll(",", "").replaceAll(" ", "").replaceAll("-", ""),"0"));	//영업이익 분기
	Long quarter2 = Double.parseDouble(StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(18).text().replaceAll(",", "").replaceAll(" ", "").replaceAll("-", ""),"0"));	//영업이익 분기
	Long quarter3 = Double.parseDouble(StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(19).text().replaceAll(",", "").replaceAll(" ", "").replaceAll("-", ""),"0"));	//영업이익 분기
	if(quarter3 == 0){
		quarter3 = (quarter1+quarter2)/2;
	}
	
	//연도별 영업이익
	//Long profitLastYear = Double.parseDouble(StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(12).text().replaceAll(",", "").replaceAll(" ", "").replaceAll("-", ""),"0"));	//영업이익 작년
	Long profitYear2 = Double.parseDouble(StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(13).text().replaceAll(",", "").replaceAll(" ", "").replaceAll("-", ""),"0"));	//영업이익 당해
	if(profitYear2 == 0){
		profitYear2 = (quarter1 + quarter2 + quarter3)/3;
	}
	
	//ROE 연간
	Float roeYear1 = Double.parseDouble(StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(51).text().replaceAll(",", "").replaceAll(" ", "").replaceAll("-", ""),"0"));	//영업이익 작년
	Float roeYear2 = Double.parseDouble(StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(52).text().replaceAll(",", "").replaceAll(" ", "").replaceAll("-", ""),"0"));	//영업이익 작년
	Float roeYear3 = Double.parseDouble(StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(53).text().replaceAll(",", "").replaceAll(" ", "").replaceAll("-", ""),"0"));	//영업이익 작년
	
	//ROE 분기
	Float roeQuarter1 = Double.parseDouble(StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(57).text().replaceAll(",", "").replaceAll(" ", "").replaceAll("-", ""),"0"));	//영업이익 작년
	Float roeQuarter2 = Double.parseDouble(StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(58).text().replaceAll(",", "").replaceAll(" ", "").replaceAll("-", ""),"0"));	//영업이익 작년
	Float roeQuarter3 = Double.parseDouble(StringUtils.defaultIfEmpty(doc2.select("div[class=sub_section] table.tb_type1_ifrs tbody tr td").eq(59).text().replaceAll(",", "").replaceAll(" ", "").replaceAll("-", ""),"0"));	//영업이익 작년
	if(roeYear3 == 0){
		roeYear3 = (roeQuarter1 + roeQuarter2 + ((roeQuarter1 + roeQuarter2)/2))/3;
	}
	
	//연간 ROE 평균
	Float roeAvg = (roeYear1 + roeYear2 + roeYear3)/3;
	
	//영업이익 * ROE 3년평균 
	Float t = (profitYear2 * roeAvg)/marketSum;
	
	
	System.out.println("[S]==============");
	System.out.println("종목명 : " + companyName);
	System.out.println("시가총액 : " + marketSum);
	//System.out.println("영업이익 작년 : " + profitLastYear);
	System.out.println("영업이익 : " + profitYear2);
	//System.out.println("영업이익 분기1 : " + quarter1);
	//System.out.println("영업이익 분기2 : " + quarter2);
	//System.out.println("영업이익 분기3 : " + quarter3);
	System.out.println("ROE 연간1 : " + roeYear1);
	System.out.println("ROE 연간2 : " + roeYear2);
	System.out.println("ROE 연간3 : " + roeYear3);
	System.out.println("ROE 평균 : " + roeAvg);
	System.out.println("최종값 : " + t);
	System.out.println("==============[E]");
	*/
%>

<script>
	$(document).ready(function(){
		$("#table").tablesorter();
		setMt();
		$("#table thead th:last").click();
		$("#table thead th:last").click();
	});
	
	function setMt(){
		$(".py").each(function(){
			var idNum = $(this).attr("id");
			var mt = $("#mt").val()+'00000000';
			var mtVal = (Number($(this).text()) * mt) / Number($(this).attr("stcQt"));
			mtVal = Math.floor(mtVal);
			var price = $(this).attr("price").replace(/,/gi, "");
			
			if(mtVal > price){
				var per = (mtVal - price) / price * 100;
				//per = String(per).match(/\d*.?(\w{3})?/)[1];
				$("#mt"+idNum).html("<font color='#03c75a'>"+numberWithCommas(mtVal)+ " (" + parseInt(per)  + "%)</font>");
				$("#mt"+idNum).parent().addClass("show");
			}else{
				$("#mt"+idNum).text(numberWithCommas(mtVal));
			}
			
			
		});
		showMt();
	}
	
	function numberWithCommas(x) {
		return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	}
	
	function showMt(){
		$("#table tr").hide();
		$(".show").show();
	}
	
	function allShowMt(){
		$("#table tr").show();
	}
</script>