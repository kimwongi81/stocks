<%@ page contentType="text/html; charset=utf-8" %>

<%@ page import="org.jsoup.Jsoup" %>
<%@ page import="org.jsoup.nodes.Document" %>
<%@ page import="org.jsoup.select.Elements" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>

<style>
  table {
    width: 40%;
    border: 1px solid #444444;
    border-collapse: collapse;
    float: left;
    margin-left: 20px;
    margin-top: 20px;
  }
  th, td {
    border: 1px solid #444444;
    padding: 10px;
  }
</style>

<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script type="text/javascript" src="/js/jquery-latest.js"></script>
<script type="text/javascript" src="/js/jquery.tablesorter.js"></script>


<link class="include" rel="stylesheet" type="text/css" href="/js/chart/jquery.jqplot.min.css" />
<script type="text/javascript" src="/js/chart/jquery.jqplot.js"></script>
<script type="text/javascript" src="/js/chart/shBrushJScript.min.js"></script>
<script type="text/javascript" src="/js/chart/shBrushXml.min.js"></script>
<script type="text/javascript" src="/js/chart/shCore.min.js"></script>
<script type="text/javascript" src="/js/chart/plugins/jqplot.dateAxisRenderer.js"></script>
<script type="text/javascript" src="/js/chart/plugins/jqplot.cursor.js"></script>
<script type="text/javascript" src="/js/chart/plugins/jqplot.highlighter.js"></script>

<%
	//업종 
	String url = "https://finance.naver.com/sise/sise_group.nhn?type=upjong";
	Document doc = Jsoup.connect(url).get();
	Elements elm = doc.select("div#contentarea_left table td a");
	
	//종목 링크 구하기.
	String[] itmLinkList = new String[elm.size()];
	for(int i=0; elm.size() > i; i++ ){
		itmLinkList[i] = elm.get(i).attr("href");
	}


%>
<a href="/siga.jsp">시가총액</a>

<p>
<div id="chart1" style="height:300px; width:500px; margin-left:50px;"></div>

<p>
<table id="table1" class="tablesorter">
	<thead>
	<tr>
		<th style="width: 200px;">업종</th>
	</tr>
	</thead>
	<tbody>
<%	
	for(int i=0; elm.size() > i; i++ ){
		String linkUrl = elm.get(i).attr("href").replaceAll("/sise/sise_group_detail.naver", "http://localhost:8080/index.jsp");
		String companyName = elm.get(i).text();
%>
			<tr>
				<td><a href="<%=linkUrl %>&themeNm=<%=companyName %>"><%=companyName %></a></td>
			</tr>
<%		
	}

%>
	</tbody>
</table>

<table id="table2" class="tablesorter">
	<thead>
	<tr>
		<th style="width: 200px;">테마</th>
	</tr>
	</thead>
	<tbody>
<%	
	for(int i=0; 6 > i; i++ ){
		String themeUrl = "https://finance.naver.com/sise/theme.naver?&page="+i;
		Document tdoc = Jsoup.connect(themeUrl).get();
		Elements telm = tdoc.select("div#contentarea_left table td.col_type1 a");

	for(int j=0; telm.size() > j; j++ ){
		String linkUrl = telm.get(j).attr("href").replaceAll("/sise/sise_group_detail.naver", "http://localhost:8080/index.jsp");
		String companyName = telm.get(j).text();
%>
		<tr>
			<td><a href="<%=linkUrl %>&themeNm=<%=companyName %>"><%=companyName %></a></td>
		</tr>
<%		
		}
	}

%>
	</tbody>
</table>

<script>
	$(document).ready(function(){
		$(".tablesorter").tablesorter();
		
		//document.getElementsByTagName("table")[0].tBodies[0].rows.length
		
		// Enable plugins like cursor and highlighter by default.
		$.jqplot.config.enablePlugins = true;
		// For these examples, don't show the to image button.
		$.jqplot._noToImageButton = true;
	
		var goog = [["3/2/2021", 9],
				  ["3/3/2021", 32],
				  ["3/4/2021", 43],
				  ["3/5/2021", 47],
				  ["3/8/2021", 19],
				  ["3/9/2021", 23],
				  ["3/10/2021", 26],
				  ["3/11/2021", 33],
				  ["3/12/2021", 42],
				  ["3/15/2021", 23],
				  ["3/16/2021", 43],
				  ["3/17/2021", 49],
				  ["3/18/2021", 59],
				  ["3/19/2021", 73],
				  ["3/22/2021", 33],
				  ["3/23/2021", 42],
				  ["3/24/2021", 60],
				  ["3/25/2021", 77],
				  ["3/26/2021", 78],
				  ["3/29/2021", 48],
				  ["3/30/2021", 63],
				  ["3/31/2021", 83],
				  ["4/1/2021", 82],
				  ["4/2/2021", 104],
				  ["4/5/2021", 58],
				  ["4/6/2021", 79],
				  ["4/7/2021", 98],
				  ["4/8/2021", 125],
				  ["4/9/2021", 143],
				  ["4/12/2021", 46],
				  ["4/13/2021", 64],
				  ["4/14/2021", 87],
				  ["4/15/2021", 94],
				  ["4/16/2021", 115],
				  ["4/19/2021", 41],
				  ["4/20/2021", 73],
				  ["4/21/2021", 73],
				  ["4/22/2021", 100],
				  ["4/23/2021", 127],
				  ["4/26/2021", 74]
				  ];
		
		opts = {
		  title: '52주 신고가',
		  series: [{
			  neighborThreshold: 0
		  }],
		  axes: {
			  xaxis: {
				renderer:$.jqplot.DateAxisRenderer,
				min:'March 1, 2021',
				tickInterval: "2 months",
				tickOptions:{formatString:"%Y/%#m/%#d"}
			  },
			  yaxis: {
				  // renderer: $.jqplot.LogAxisRenderer,
				  //tickOptions:{prefix: '$'}
			  }
		  },
		  cursor:{zoom:true}
	  };
	 
	  plot1 = $.jqplot('chart1', [goog], opts);

	$("#table1 thead th:last").click()
	$("#table2 thead th:last").click()
	});
</script>