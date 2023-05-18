<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="vo.*" %>
<%
	//인코딩
	request.setCharacterEncoding("utf-8");

	//final 변수(상수)를 사용하여 가독성을 높임
	final String RESET = "\u001B[0m"; 
	final String YELLOW = "\u001B[43m";
	
	// 파라미터값 확인
	System.out.println(request.getParameter("currentPage") + "<-- empListBySerch parm currentPage 값");
																//디버깅 설명을 적을 때 페이지이름 파라값인지 일반값인지 알수있는 적은 뒤 마지막은 출력될부분을 적는것이 보기 쉽다.
	System.out.println(request.getParameter("serchWord")+ "<-- empListBySerch parm serchWord 값");
	System.out.println(request.getParameter("rowPerPage"));

	//페이지 만들기
	//현재페이지 설정
	// 위에 널값이 나왔으니 파라미터값 null 유효성 검사 currentPage는 널값이면안됨
	// 블럭안에 int currentPage 를 사용하게 되면 블럭의 생명주기로 인해 블럭 밖에서는 currentPage를 사용할 수 없다.
	// 따라서 int currentPage 를 블럭 밖으로 빼서 선언해준다.
	int currentpage = 1;
	if(request.getParameter("currentpage") != null){
		currentpage = Integer.parseInt(request.getParameter("currentpage"));
		// ↑↑ currentPage에 값이 있을 떄 currentPage의 값을 currentPage에 넣어주는 코드
			} /* else{
				currentPage = 1;
			}*/ //원래는 위에 1값을 주지않고 else로 밑에 값을 줬지만 코드를 줄이기위해 블럭 밖에서 currentPage의 값을 1로 넣어주면 else를 사용하지않아도 괜찮아진다.
			// 기본값을 1로 설정했기때문에..
	System.out.println(currentpage + YELLOW+"<-- 현재 currentpage");
	
	//출력 할 리스트 행 갯수 설정
	int outPutPage = 10;
	
	//페이지 넘길 때 시작하는 행 번호 설정
	int startrow = (currentpage - 1) * outPutPage;
	
	//젠더 요청값 구하기
	String gender = ""; //searchWord는 스트링 값이여서 기본값이 null값이지만 if문에서 null값 공백값을 다 비교해서 하기에는 코드가 길어지니 
						// 코드를 줄이기 위해 미리 ""공백으로 바꾸어놓고 if문을 사용하면 코드를 줄일 수 있다
	if(request.getParameter("gender") != null){
		gender = request.getParameter("gender");
	}
	System.out.println(gender + "<-- 현재 gender");
	
	//searchWord 요청값 구하기
	String searchWord = "";
	if(request.getParameter("searchWord") != null){
		searchWord = request.getParameter("searchWord");
	}
	
	//입사년도 요청값 구하기
	//시작 입사년도
	String beginYear = "";
	if(request.getParameter("beginYear") != null){
		beginYear = request.getParameter("beginYear");
	}
	System.out.println(beginYear + YELLOW+"<-- 현재 beginYear");
	//끝 입사년도
	String endYear = "";
	if(request.getParameter("endYear") != null){
		endYear = request.getParameter("endYear");
	}
	System.out.println(endYear + YELLOW+"<-- 현재 endYear");
	
	//월 입력 조회 만들기
	String[] ckMonth = request.getParameterValues("ckMonth"); //스트링 배열
	//정수배열로 변환
	int[] intCkMonth = null;
	//체크하기위한 배열 설정하기
	boolean[] mChecked = new boolean[13];
	
	// ckMonth 값이 들어왔을 때 변환해서 정수배열에 추가
	if(ckMonth != null){
		intCkMonth = new int[ckMonth.length];
		for(int i=0; i<intCkMonth.length; i+=1){
			//ckMonth에 들어온 i값을 int로 변환하여 intCkMonth i 값에 넣어준다.
			intCkMonth[i] = Integer.parseInt(ckMonth[i]);
			//체크를 하기 위한 true 값 넣어주기
			mChecked[intCkMonth[i]] = true;
		}		
	}
	
	//ckMonth 값 디버깅
	if(request.getParameter("ckMonth") != null){
		for(String m : request.getParameterValues("ckMonth")){
			System.out.println(m + "<--ckMonth 에들어온 값");
		}
	}
	
	//첫 페이지 설정 해줬으니 디비 연결
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/employees","root","java1234");
	//sql설정하기
	/*
		SELECT
		emp_no empNo,
		birth_date birthDate,
		first_name firstName,
		last_name lastName,
		gender gender,
		hire_date hireDate
		YEAR(birth_date) byear,
		MONTH(birth_date) bmonth,
		DAY(birth_date) bday
		FROM employees
		LIMIT ?, ?;
	*/
	
	//if문 분기를 너무 많이 해줘야하기때문에 간단하게 코드 정리를 하기 위해 sql 기본설정을 해주었다.
	// 시작하는 sql 구문
	String sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees where CONCAT(first_name,' ',last_name) LIKE ?";
	//끝나는 sql 구문
	String endsql = "LIMIT ?, ?";

	// 위에서 값들을 공백으로 설정해주었기 때문에 출력할때 공백이여도 무관하다.
	// 따라서 간단하게 코드를 정리하기위해 미리 쿼리문을 설정해주었다.
	String genderQuery = "";
	if(!gender.equals("")){ //gender 값이 있을 때
		genderQuery = " and gender= '" + gender + "'"; //기본으로설정한 쿼리문 뒤에 붙는 부분을 설정해주었다.
													// 중간에 '를 쓰는 이유는 문자열을 그대로 쓰게되면 문자열로만 인식을 하기 때문에 쿼리문을 연결해주기 위해 '를 사용해서 연결시켜주었다.
	}
	String yearQuery = "";
	if(!beginYear.equals("") && endYear.equals("")){ // 비긴이얼에 갑싱 있고 엔드이얼에 값이 없을 때
		yearQuery = " and year(hire_date) >= '" + beginYear + "'";
	}
	if(beginYear.equals("") && !endYear.equals("")){ //비긴이얼에 값이 없고 엔드이얼에 값이 있을 때
		yearQuery = " and year(hire_date) <= '" + endYear + "'";
	}
	if(!beginYear.equals("") && !endYear.equals("")){ //비긴이얼에 값이 있고 엔드이얼에 값이 없을 때
		yearQuery = " and year(hire_date) between '" + beginYear + "' and '" + endYear + "'";
	}
	if(intCkMonth != null){ // 월 선택 부분 셋팅
		sql += " AND MONTH(hire_date) IN (?";
		// 쿼리에 ?의 갯수를 셋팅
		for(int i=1; i<intCkMonth.length; i+=1){
			sql += ",?";
		}
		sql += ")";
	}
	// 설정해놓은 모든 쿼리 연결
	sql += genderQuery + yearQuery + endsql;
	
	PreparedStatement stmt = conn.prepareStatement(sql);
	
	// 쿼리에 ?값을 셋팅
	stmt.setString(1, "%"+searchWord+"%");
	int ckMonthCnt = 0;
	if(intCkMonth != null){
		ckMonthCnt = intCkMonth.length;
		for(int i=0; i<ckMonthCnt; i+=1){
			stmt.setInt(i+2, intCkMonth[i]);
		}
	}
	stmt.setInt(ckMonthCnt+2, startrow);
	stmt.setInt(ckMonthCnt+3, outPutPage);
	
	// 페이지 넘길 때 체크된 월 값 같이 넘겨주기 위한 문자열
	String ckMonthNext = "";
	if(intCkMonth != null){
		for(int i=0; i<intCkMonth.length; i+=1){
			ckMonthNext += "&ckMonth=" + intCkMonth[i];
		}
	}
	System.out.println(ckMonthNext + "<--ckMonthNext");
	
	
	//디버깅
	System.out.println(stmt + "<-- stmt 값");
	ResultSet rs = stmt.executeQuery();
	
	//에리아리스트 설정, 리스트를 나오게 하자
	ArrayList<EmpList> empList = new ArrayList<EmpList>();
	while(rs.next()){
		EmpList e = new EmpList();
		e.empNo = rs.getInt("empNo");
		e.birthDate = rs.getString("birthDate");
		e.firstName = rs.getString("firstName");
		e.lastName = rs.getString("lastName");
		e.gender = rs.getString("gender");
		e.hireDate = rs.getString("hireDate");
		// 짤라온 sql문을 에리아리스트에 넣어준다.
		e.byear = rs.getInt("byear");
		e.bmonth = rs.getInt("bmonth");
		e.bday = rs.getInt("bday");
		empList.add(e);
	}
	
	//마지막 페이지 설정
	//sql설정
	/*
		SELECT count(*) from employees
	*/
	String sql2 = "SELECT count(*) from employees";
	if(!gender.equals("")){
		sql2 = "SELECT count(*) from employees where gender = '" + gender + "'";
	}
	PreparedStatement stmt2 = conn.prepareStatement(sql2);
	ResultSet rs2 = stmt2.executeQuery();
	//디버깅 확인
	System.out.println(stmt2 +"<-- stmt2 값");
	
	//토탈로우 설정.
	int totalRow = 0;
	if(rs2.next()){
		totalRow = rs2.getInt("count(*)");
	}
	//마지막페이지 출력했을 때 남는 행 있으면 어떻게 해야하는지 설정
	int lastPage = totalRow/outPutPage;
	if(totalRow % outPutPage != 0){
		lastPage = lastPage +1;
	}
	
	//나이 출력
	//캘린더 가져오기
	Calendar today = Calendar.getInstance();
	int year = today.get(Calendar.YEAR);
	int month = today.get(Calendar.MONTH);
	int day = today.get(Calendar.DATE);
%>    
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Insert title here</title>
	<style>
		table, td, th {
			border: 1px solid #BDBDBD; 
		}
		table {
			border-collapse: collapse;
			width: 1280px;
			height: 600px;
			background-color: #F6F6F6;
			text-align: center;
			margin: 0 auto;
		}
		th{
			background-color: #FFB2D9;
			height: 50px;
		}
		.content{
			text-align: center;
			margin-top: 50px;
		}
		footer{
			width: 1280px;
			margin: 0 auto;
		}
	</style>
</head>
<body>
	<h1 style="text-align: center; font-size: 50px;"><img alt="*" src="./img/job-seeker.png" style="width: 50px; margin-right: 15px;">emp List</h1>
	<div class="content">
		<div style="margin-bottom: 20px;">
			<form action="./empList2.jsp" method="get">
			<label>성별 : </label>
			<select name="gender">
			<%
				if(gender.equals("")){
			%>
					<option value="" selected="selected">선택</option>
					<option value="M">남</option>
					<option value="F">여</option>
			<%		
				}else if(gender.equals("M")){
			%>
					<option value="" >선택</option>
					<option value="M" selected="selected">남</option>
					<option value="F">여</option>
			<%							
				}else if(gender.equals("F")){
			%>
					<option value="">선택</option>
					<option value="M">남</option>
					<option value="F" selected="selected">여</option>
			<%		
				}
			%>
			</select>
			<label>이름검색 : </label>
			<input type="text" name="searchWord" value="<%=searchWord%>">
			<label>입사년도 : </label>
			<input type="number" name="beginYear" value="<%=beginYear%>">
			~
			<input type="number" name="endYear" value="<%=endYear%>">
			<div>
			<%
				int[] months = {1,2,3,4,5,6,7,8,9,10,11,12};
				for(int m : months){
			%>
				<input type="checkbox" name="ckMonth" value=<%=m%> <%if(mChecked[m]){%>checked<%} %>><%=m%>월
			<%		
				}
			%>
			</div>
			<button type="submit">조회</button>
		</form>
		</div>
		<table>
			<tr>
				<th>
					empNo
<%-- 					<a href="./empList.jsp?col=emp_no&aseDesc=ASC&gender=<%=gender%>">[asc]</a>
					<a href="./empList.jsp?col=emp_no&aseDesc=DESC&gender=<%=gender%>">[desc]</a> --%>
				</th>
				<th>
					birthDate
					<%-- <a href="./empList.jsp?col=birth_date&aseDesc=ASC&gender=<%=gender%>">[asc]</a>
					<a href="./empList.jsp?col=birth_date&aseDesc=DESC&gender=<%=gender%>">[desc]</a> --%>
				</th>
				<th>
					age
					<%-- <a href="./empList.jsp?col=birth_date&aseDesc=DESC&gender=<%=gender%>">[asc]</a>
					<a href="./empList.jsp?col=birth_date&aseDesc=ASC&gender=<%=gender%>">[desc]</a> --%>
				</th>
				<th>
					firstName
					<%-- <a href="./empList.jsp?col=first_name&aseDesc=ASC&gender=<%=gender%>">[asc]</a>
					<a href="./empList.jsp?col=first_name&aseDesc=DESC&gender=<%=gender%>">[desc]</a> --%>
				</th>
				<th>
					lastName
					<%-- <a href="./empList.jsp?col=last_name&aseDesc=ASC&gender=<%=gender%>">[asc]</a>
					<a href="./empList.jsp?col=last_name&aseDesc=DESC&gender=<%=gender%>">[desc]</a> --%>
				</th>
				<th>
					gender
					<%-- <a href="./empList.jsp?col=gender&aseDesc=ASC&gender=<%=gender%>">[asc]</a>
					<a href="./empList.jsp?col=gender&aseDesc=DESC&gender=<%=gender%>">[desc]</a> --%>
				</th>
				<th>
					hireDate
					<%-- <a href="./empList.jsp?col=hire_date&aseDesc=ASC&gender=<%=gender%>">[asc]</a>
					<a href="./empList.jsp?col=hire_date&aseDesc=DESC&gender=<%=gender%>">[desc]</a> --%>
				</th>
			</tr>
			<%
				for(EmpList e : empList){
			%>
			<tr>
				<td><%=e.empNo%></td>
				<td><%=e.birthDate%></td>
			<%
				// 캘린더 year 와 가져온 byear을 빼서 현재 나이 구하기			
				int age = year - e.byear;	
				if(e.bmonth < month && e.bday < day){
					// 만약 달과 일이 지났으면 +1해서 나이 계산
			%>
					<td><%=age = age+1 %></td>
			<%		
				}else{
			%>
					<td><%=age = age-1 %></td>
			<%		
				}
			%>	
				<td><%=e.firstName%></td>
				<td><%=e.lastName%></td>
				<td><img alt="*" src="./img/<%=e.gender%>.png"></td>
				<td><%=e.hireDate%></td>
			</tr>
		<%		
			}
		%>
		</table>
	</div>
	<footer>
		<%
				if(currentpage > 1){
			%>
					<a href="./empList2.jsp?currentpage=<%=currentpage-1%>&gender=<%=gender%>&searchWord=<%=searchWord%>&beginYear=<%=beginYear%>&endYear=<%=endYear%>&ckMonthNext=<%=ckMonthNext%>"style="float: left; padding-left: 10px;"><img alt="+" src="./img/next1.png"></a>
			<%		
				}
				if(currentpage < lastPage){
			%>
					<div style="margin-top: 30px; font-size: 25px; text-align: center;" ><%=currentpage %> 페이지	
					<a href="./empList2.jsp?currentpage=<%=currentpage+1%>&gender=<%=gender%>&searchWord=<%=searchWord%>&beginYear=<%=beginYear%>&endYear=<%=endYear%>&ckMonthNext=<%=ckMonthNext%>"style="float: right; padding-right: 10px;"><img alt="+" src="./img/next.png"></a></div>
			<%		
				}
			%>
	</footer>
</body>
</html>