import streamlit as st
import pandas as pd
import pg8000
import plotly.express as px

# 1. Page Configuration (Must be the first Streamlit command)
st.set_page_config(page_title="Resort Data Warehouse", layout="wide")

# 2. Database Connection Function
# @st.cache_resource ensures Streamlit only connects once, saving memory and time!
@st.cache_resource
def init_connection():
    try:
        return pg8000.connect(
            host="localhost",
            port="5432",
            database="postgres", # Change if you named your DB differently
            user="postgres",     # Default username
            password="YOUR_LOCAL_PASSWORD" # Replace with your actual password²
        )
    except Exception as e:
        st.error(f"Failed to connect to database: {e}")
        return None

# Initialize the connection
conn = init_connection()

# 3. Build the Tab Architecture
st.title("🏨 Resort Data Warehouse Dashboard")

# Create the 3 tabs
tab1, tab2, tab3 = st.tabs([
    "🏗️ 1. Architecture", 
    "📊 2. Executive Summary", 
    "🔍 3. Decisional Queries"
])

# --- TAB 1: ARCHITECTURE ---
with tab1:
    st.header("Data Warehouse Architecture")
    st.markdown("""
    This section outlines the backend structure of the Resort Data Warehouse. 
    The database utilizes a hybrid **Star/Snowflake Schema** design to optimize for fast OLAP (Online Analytical Processing) queries.
    """)
    
    st.divider()

    # 1. Display the Image
    st.subheader("Entity-Relationship Diagram (ERD)")
    try:
        # Streamlit looks for this image file in your folder
        st.image("Schema.png", caption="Resort Data Warehouse Schema", use_container_width=True)
    except FileNotFoundError:
        st.warning("🖼️ Image not found. Please save your DBeaver diagram as 'erd_schema.png' in the same folder as this app.")

    st.divider()

    # 2. Display the Technical Summary
    st.subheader("Schema Details")
    
    # Using columns to make a neat layout
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("""
        **Data Marts (Fact Tables):**
        * `FACT_ROOM_RENTAL` (Core booking events)
        * `FACT_PAYMENT` (Financial transactions)
        * `FACT_POOL_RENTAL` (Amenity utilization)
        * `FACT_SERVICE_RENTAL` (Wellness cross-selling)
        * `FACT_INVESTMENT` (Corporate capital allocation)
        * `FACT_STOCK_PRICE_HISTORY` (Market tracking)
        """)
        
    with col2:
        st.markdown("""
        **Conformed Dimensions:**
        * `DIM_DATE` (Time hierarchy)
        * `DIM_PERSON` (Demographics & Social Media)
        * `DIM_RESORT` (Location hierarchy)
        * `DIM_ROOM` & `DIM_SWIMMING_POOL` (Facilities)
        * `DIM_SPECIFIC_SERVICE` (Wellness catalog)
        * `DIM_SPECIAL_OFFER` (Promotions)
        * `DIM_STOCK_MARKET_TITLE` (Financial instruments)
        """)

# --- TAB 2: EXECUTIVE SUMMARY ---
with tab2:
    st.header("Executive Summary: KPIs & Trends")
    
    if conn is not None:
        # 1. Add an interactive filter for the executives
        selected_year = st.radio(
            "Filter Dashboard by Year:",
            options=["All Time", "2026", "2025", "2024"],
            horizontal=True
        )

        # Build the SQL WHERE clause based on what the user clicks
        where_clause = ""
        if selected_year != "All Time":
            where_clause = f"WHERE d_date.Year = {selected_year}"

        # 2. Create the 3 KPI Cards
        kpi1, kpi2, kpi3 = st.columns(3)

        # Fetch Revenue
        rev_query = f"SELECT SUM(f.Amount) FROM FACT_PAYMENT f JOIN DIM_DATE d_date ON f.DateKey = d_date.DateKey {where_clause};"
        rev_df = pd.read_sql(rev_query, conn)
        total_rev = rev_df.iloc[0,0]
        total_rev = total_rev if pd.notna(total_rev) else 0 # Handles empty years safely
        kpi1.metric("Total Revenue", f"${total_rev:,.2f}")

        # Fetch Rooms
        room_query = f"SELECT SUM(f.RentalCount) FROM FACT_ROOM_RENTAL f JOIN DIM_DATE d_date ON f.DateKey = d_date.DateKey {where_clause};"
        room_df = pd.read_sql(room_query, conn)
        total_rooms = room_df.iloc[0,0]
        total_rooms = total_rooms if pd.notna(total_rooms) else 0
        kpi2.metric("Total Room Rentals", int(total_rooms))

        # Fetch Investments
        inv_query = f"SELECT SUM(f.Amount) FROM FACT_INVESTMENT f JOIN DIM_DATE d_date ON f.DateKey = d_date.DateKey {where_clause};"
        inv_df = pd.read_sql(inv_query, conn)
        total_inv = inv_df.iloc[0,0]
        total_inv = total_inv if pd.notna(total_inv) else 0
        kpi3.metric("Total Corporate Investment", f"${total_inv:,.2f}")
        
        # 3. Create a SECOND row of KPI Cards (Efficiency & Operations)
        st.write("") # Adds a tiny bit of vertical space
        kpi4, kpi5, kpi6 = st.columns(3)

        # Fetch Average Spend Per Customer
        avg_spend_query = f"""
            SELECT SUM(f.Amount) / NULLIF(COUNT(DISTINCT f.PersonKey), 0) 
            FROM FACT_PAYMENT f 
            JOIN DIM_DATE d_date ON f.DateKey = d_date.DateKey {where_clause};
        """
        avg_df = pd.read_sql(avg_spend_query, conn)
        avg_spend = avg_df.iloc[0,0]
        avg_spend = avg_spend if pd.notna(avg_spend) else 0
        kpi4.metric("Avg Spend per Customer", f"${avg_spend:,.2f}")

        # Fetch Total Wellness Bookings
        wellness_query = f"SELECT SUM(f.RentalCount) FROM FACT_SERVICE_RENTAL f JOIN DIM_DATE d_date ON f.DateKey = d_date.DateKey {where_clause};"
        well_df = pd.read_sql(wellness_query, conn)
        total_well = well_df.iloc[0,0]
        total_well = total_well if pd.notna(total_well) else 0
        kpi5.metric("Total Wellness Bookings", int(total_well))

        # Fetch Average Pool Duration
        pool_query = f"SELECT AVG(f.Duration) FROM FACT_POOL_RENTAL f JOIN DIM_DATE d_date ON f.DateKey = d_date.DateKey {where_clause};"
        pool_df = pd.read_sql(pool_query, conn)
        avg_pool = pool_df.iloc[0,0]
        avg_pool = avg_pool if pd.notna(avg_pool) else 0
        kpi6.metric("Avg Pool Duration (Mins)", f"{avg_pool:,.0f}")
        st.divider()
        
        # 4. Add the Revenue Trend Chart
        st.subheader("Revenue Trend Over Time")
        
        trend_query = f"""
            SELECT d_date.Year, d_date.Month, SUM(f.Amount) as Monthly_Revenue
            FROM FACT_PAYMENT f
            JOIN DIM_DATE d_date ON f.DateKey = d_date.DateKey
            {where_clause}
            GROUP BY 1, 2
            ORDER BY 1, 2;
        """
        trend_df = pd.read_sql(trend_query, conn)
        
        if not trend_df.empty:
            # Create a clean "YYYY-MM" timeline for the X-Axis
            trend_df["Timeline"] = trend_df["year"].astype(str) + "-" + trend_df["month"].astype(str).str.zfill(2)
            
            fig_trend = px.area(
                trend_df, x="Timeline", y="monthly_revenue", markers=True,
                title="Monthly Revenue Accumulation",
                labels={"Timeline": "Date (Year-Month)", "monthly_revenue": "Revenue ($)"}
            )
            st.plotly_chart(fig_trend, use_container_width=True)
        else:
            st.info("No revenue data available for the selected period.")

# --- TAB 3: DECISIONAL QUERIES ---
with tab3:
    st.header("Interactive Business Queries")
    
    if conn is not None:
        # 1. The FULL Dropdown Menu
        query_selection = st.selectbox(
            "Select a Business Question to Analyze:",
            [
                "Select a query...", 
                "Query 1: Revenue by Resort, Gender & Age",
                "Query 2: Avg Expenditure by Social Media Status",
                "Query 3: Peak Season Room Rentals",
                "Query 4: Wellness Services by Age",
                "Query 5: Pool Duration (Free vs Paid)",
                "Query 6: Cross-Selling Rate (Rooms + Services)",
                "Query 7: Discount Volume by Social Media",
                "Query 8: Discount Impact on Wellness Services",
                "Query 9: Corporate Investments by Stock Type",
                "Query 10: Stock Market Value Fluctuations"
            ]
        )

        # ==========================================
        # QUERY 1
        # ==========================================
        if query_selection == "Query 1: Revenue by Resort, Gender & Age":
            st.subheader("Total revenue collected by each Resort, grouped by Gender and Age bracket (Last 3 Years)")
            
            sql_q1 = """
            SELECT 
                d_resort.ResortName, d_person.Gender,
                CASE 
                    WHEN d_person.Age BETWEEN 18 AND 30 THEN '18-30'
                    WHEN d_person.Age BETWEEN 31 AND 50 THEN '31-50'
                    ELSE '51+' 
                END AS Age_Bracket,
                SUM(f_pay.Amount) AS Total_Revenue
            FROM FACT_PAYMENT f_pay
            JOIN DIM_RESORT d_resort ON f_pay.ResortKey = d_resort.ResortKey
            JOIN DIM_PERSON d_person ON f_pay.PersonKey = d_person.PersonKey
            JOIN DIM_DATE d_date ON f_pay.DateKey = d_date.DateKey
            WHERE d_date.Year >= 2021
            GROUP BY 1, 2, 3
            ORDER BY Total_Revenue DESC;
            """
            
            with st.expander("View the SQL Code"):
                st.code(sql_q1, language='sql')
            
            df_q1 = pd.read_sql(sql_q1, conn)
            fig_q1 = px.bar(
                df_q1, x="resortname", y="total_revenue", color="gender", facet_col="age_bracket",
                title="Revenue Breakdown by Demographics",
                labels={"resortname": "Resort", "total_revenue": "Total Revenue ($)"}
            )
            fig_q1.update_xaxes(matches=None) # Removes empty spaces
            st.plotly_chart(fig_q1, use_container_width=True)
            st.dataframe(df_q1)

        # ==========================================
        # QUERY 2
        # ==========================================
        elif query_selection == "Query 2: Avg Expenditure by Social Media Status":
            st.subheader("Average expenditure: Social Media followers vs. non-followers by year")
            
            sql_q2 = """
            SELECT 
                d_date.Year,
                CASE 
                    WHEN d_person.SocialMediaType = 'None' THEN 'No Social Media'
                    ELSE 'Follows on Social Media' 
                END AS Social_Media_Status,
                AVG(f_pay.Amount) AS Average_Expenditure
            FROM FACT_PAYMENT f_pay
            JOIN DIM_PERSON d_person ON f_pay.PersonKey = d_person.PersonKey
            JOIN DIM_DATE d_date ON f_pay.DateKey = d_date.DateKey
            GROUP BY 1, 2
            ORDER BY d_date.Year;
            """
            
            with st.expander("View the SQL Code"):
                st.code(sql_q2, language='sql')
            
            df_q2 = pd.read_sql(sql_q2, conn)
            fig_q2 = px.bar(
                df_q2, x="year", y="average_expenditure", color="social_media_status", barmode="group",
                title="Impact of Social Media on Customer Spending",
                labels={"year": "Year", "average_expenditure": "Average Spend ($)"}
            )
            fig_q2.update_xaxes(type='category')
            st.plotly_chart(fig_q2, use_container_width=True)
            st.dataframe(df_q2)

        # ==========================================
        # QUERY 3
        # ==========================================
        elif query_selection == "Query 3: Peak Season Room Rentals":
            st.subheader("Total Room rentals by Room Type and Hotel during Peak Season (Months 6, 7, 8)")
            
            sql_q3 = """
            SELECT 
                d_date.Month, d_room.HotelName, d_room.RoomType,
                SUM(f_room.RentalCount) AS Total_Rentals
            FROM FACT_ROOM_RENTAL f_room
            JOIN DIM_ROOM d_room ON f_room.RoomKey = d_room.RoomKey
            JOIN DIM_DATE d_date ON f_room.DateKey = d_date.DateKey
            WHERE d_date.Month IN (6, 7, 8)
            GROUP BY 1, 2, 3
            ORDER BY Total_Rentals DESC;
            """
            
            with st.expander("View the SQL Code"):
                st.code(sql_q3, language='sql')
            
            df_q3 = pd.read_sql(sql_q3, conn)
            fig_q3 = px.bar(
                df_q3, x="month", y="total_rentals", color="roomtype", facet_col="hotelname",
                title="Peak Season Room Rentals by Hotel",
                labels={"month": "Month", "total_rentals": "Volume of Rentals"}
            )
            fig_q3.update_xaxes(matches=None, type='category')
            st.plotly_chart(fig_q3, use_container_width=True)
            st.dataframe(df_q3)

        # ==========================================
        # QUERY 4
        # ==========================================
        elif query_selection == "Query 4: Wellness Services by Age":
            st.subheader("Highest volume Specific Service varying by Customer Age")
            
            sql_q4 = """
            SELECT 
                d_service.ServiceType, d_person.Age,
                SUM(f_service.RentalCount) AS Volume_Of_Rentals
            FROM FACT_SERVICE_RENTAL f_service
            JOIN DIM_SPECIFIC_SERVICE d_service ON f_service.ServiceKey = d_service.ServiceKey
            JOIN DIM_PERSON d_person ON f_service.PersonKey = d_person.PersonKey
            GROUP BY 1, 2
            ORDER BY Volume_Of_Rentals DESC;
            """
            
            with st.expander("View the SQL Code"):
                st.code(sql_q4, language='sql')
            
            df_q4 = pd.read_sql(sql_q4, conn)
            fig_q4 = px.bar(
                df_q4, x="age", y="volume_of_rentals", color="servicetype",
                title="Service Popularity across Customer Ages",
                labels={"age": "Customer Age", "volume_of_rentals": "Total Bookings"}
            )
            fig_q4.update_xaxes(type='category')
            st.plotly_chart(fig_q4, use_container_width=True)
            st.dataframe(df_q4)

        # ==========================================
        # QUERY 5
        # ==========================================
        elif query_selection == "Query 5: Pool Duration (Free vs Paid)":
            st.subheader("Average time spent in the Swimming Pool: Free Access vs Paid")
            
            sql_q5 = """
            SELECT 
                CASE 
                    WHEN d_promo.FreeAccess = TRUE THEN 'Free Access'
                    ELSE 'Paid Standard' 
                END AS Access_Type,
                AVG(f_pool.Duration) AS Average_Pool_Minutes
            FROM FACT_POOL_RENTAL f_pool
            JOIN DIM_SPECIAL_OFFER d_promo ON f_pool.SpecialOfferKey = d_promo.SpecialOfferKey
            GROUP BY 1;
            """
            
            with st.expander("View the SQL Code"):
                st.code(sql_q5, language='sql')
            
            df_q5 = pd.read_sql(sql_q5, conn)
            fig_q5 = px.bar(
                df_q5, x="access_type", y="average_pool_minutes", color="access_type",
                title="Pool Usage Duration by Access Type",
                labels={"access_type": "Access Type", "average_pool_minutes": "Average Minutes Spent"}
            )
            st.plotly_chart(fig_q5, use_container_width=True)
            st.dataframe(df_q5)

        # ==========================================
        # QUERY 6
        # ==========================================
        elif query_selection == "Query 6: Cross-Selling Rate (Rooms + Services)":
            st.subheader("What percentage of customers who Rent a Room also Rent a Specific Service?")
            
            sql_q6 = """
            WITH Room_Renters AS (
                SELECT DISTINCT PersonKey FROM FACT_ROOM_RENTAL
            ),
            Service_Renters AS (
                SELECT DISTINCT PersonKey FROM FACT_SERVICE_RENTAL
            )
            SELECT 
                (SELECT COUNT(*) FROM Room_Renters JOIN Service_Renters USING (PersonKey)) * 100.0 / 
                (SELECT COUNT(*) FROM Room_Renters) AS Cross_Sell_Percentage;
            """
            
            with st.expander("View the SQL Code"):
                st.code(sql_q6, language='sql')
            
            df_q6 = pd.read_sql(sql_q6, conn)
            cross_sell_val = df_q6.iloc[0, 0]
            
            pie_data = pd.DataFrame({
                'Category': ['Cross-Sold (Rooms + Spa)', 'Rooms Only'],
                'Percentage': [cross_sell_val, 100 - cross_sell_val]
            })
            
            fig_q6 = px.pie(
                pie_data, values='Percentage', names='Category', hole=0.4,
                title=f"Facility Cross-Selling Rate: {cross_sell_val:.1f}%"
            )
            st.plotly_chart(fig_q6, use_container_width=True)
            st.dataframe(df_q6)

        # ==========================================
        # QUERY 7
        # ==========================================
        elif query_selection == "Query 7: Discount Volume by Social Media":
            st.subheader("Room rentals utilizing a Discount, sorted by Social Media Type")
            
            sql_q7 = """
            SELECT 
                d_promo.SocialMediaType,
                SUM(f_room.RentalCount) AS Total_Discounted_Rentals
            FROM FACT_ROOM_RENTAL f_room
            JOIN DIM_SPECIAL_OFFER d_promo ON f_room.SpecialOfferKey = d_promo.SpecialOfferKey
            WHERE d_promo.DiscountPercentage > 0
            GROUP BY 1
            ORDER BY Total_Discounted_Rentals DESC;
            """
            
            with st.expander("View the SQL Code"):
                st.code(sql_q7, language='sql')
            
            df_q7 = pd.read_sql(sql_q7, conn)
            fig_q7 = px.bar(
                df_q7, x="socialmediatype", y="total_discounted_rentals", color="socialmediatype",
                title="Most Effective Social Media Promotions",
                labels={"socialmediatype": "Social Media Platform", "total_discounted_rentals": "Volume of Discounted Rentals"}
            )
            st.plotly_chart(fig_q7, use_container_width=True)
            st.dataframe(df_q7)

        # ==========================================
        # QUERY 8
        # ==========================================
        elif query_selection == "Query 8: Discount Impact on Wellness Services":
            st.subheader("Impact of Discount percentages on Specific Services by quarter")
            
            sql_q8 = """
            SELECT 
                d_date.Quarter, d_promo.DiscountPercentage,
                SUM(f_service.RentalCount) AS Total_Service_Volume
            FROM FACT_SERVICE_RENTAL f_service
            JOIN DIM_DATE d_date ON f_service.DateKey = d_date.DateKey
            CROSS JOIN DIM_SPECIAL_OFFER d_promo 
            GROUP BY 1, 2
            ORDER BY 1, 3 DESC;
            """
            
            with st.expander("View the SQL Code"):
                st.code(sql_q8, language='sql')
            
            df_q8 = pd.read_sql(sql_q8, conn)
            fig_q8 = px.line(
                df_q8, x="quarter", y="total_service_volume", color="discountpercentage", markers=True,
                title="Wellness Volume vs. Discount Rates over Quarters",
                labels={"quarter": "Financial Quarter", "total_service_volume": "Total Service Volume", "discountpercentage": "Discount (%)"}
            )
            fig_q8.update_xaxes(type='category')
            st.plotly_chart(fig_q8, use_container_width=True)
            st.dataframe(df_q8)

        # ==========================================
        # QUERY 9
        # ==========================================
        elif query_selection == "Query 9: Corporate Investments by Stock Type":
            st.subheader("Total Amount invested by the Resort into Stock Market Titles by year")
            
            sql_q9 = """
            SELECT 
                d_resort.ResortName, d_stock.StockType, d_date.Year,
                SUM(f_inv.Amount) AS Total_Invested
            FROM FACT_INVESTMENT f_inv
            JOIN DIM_RESORT d_resort ON f_inv.ResortKey = d_resort.ResortKey
            JOIN DIM_STOCK_MARKET_TITLE d_stock ON f_inv.StockKey = d_stock.StockKey
            JOIN DIM_DATE d_date ON f_inv.DateKey = d_date.DateKey
            GROUP BY 1, 2, 3
            ORDER BY Total_Invested DESC;
            """
            
            with st.expander("View the SQL Code"):
                st.code(sql_q9, language='sql')
            
            df_q9 = pd.read_sql(sql_q9, conn)
            fig_q9 = px.bar(
                df_q9, x="year", y="total_invested", color="stocktype", facet_col="resortname",
                title="Corporate Investment Portfolio by Year",
                labels={"year": "Investment Year", "total_invested": "Capital Invested ($)"}
            )
            fig_q9.update_xaxes(matches=None, type='category')
            st.plotly_chart(fig_q9, use_container_width=True)
            st.dataframe(df_q9)

        # ==========================================
        # QUERY 10
        # ==========================================
        elif query_selection == "Query 10: Stock Market Value Fluctuations":
            st.subheader("Stock Value fluctuations on average per month")
            
            sql_q10 = """
            SELECT 
                d_stock.StockType, d_date.Month, d_date.Year,
                AVG(f_price.Amount) AS Average_Monthly_Value,
                COUNT(f_price.IsChanged) AS Times_Fluctuated
            FROM FACT_STOCK_PRICE_HISTORY f_price
            JOIN DIM_STOCK_MARKET_TITLE d_stock ON f_price.StockKey = d_stock.StockKey
            JOIN DIM_DATE d_date ON f_price.DateKey = d_date.DateKey
            GROUP BY 1, 2, 3
            ORDER BY 3, 2;
            """
            
            with st.expander("View the SQL Code"):
                st.code(sql_q10, language='sql')
            
            df_q10 = pd.read_sql(sql_q10, conn)
            df_q10["Timeline"] = df_q10["year"].astype(str) + "-" + df_q10["month"].astype(str).str.zfill(2)
            
            fig_q10 = px.line(
                df_q10, x="Timeline", y="average_monthly_value", color="stocktype", markers=True,
                title="Average Monthly Stock Value Volatility",
                labels={"Timeline": "Timeline (Year-Month)", "average_monthly_value": "Avg Market Value ($)"}
            )
            st.plotly_chart(fig_q10, use_container_width=True)
            st.dataframe(df_q10)