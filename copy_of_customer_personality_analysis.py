# -*- coding: utf-8 -*-
"""Copy of Customer_personality_analysis.ipynb

Automatically generated by Colab.

Original file is located at
    https://colab.research.google.com/drive/1VEq_Zqs96R6CzothboHJdfSlvOjtmURp
"""

import pandas as pd

# Import CSV File

df = pd.read_csv('Markiting data.csv')

# Save a copy of the DataFrame to a CSV file

df_original = df.copy()

# Data overview

df.head(10)

df.info()

df.tail()

df.shape

df.describe()

# Checking for missing values

df.isna()

df.isna().sum()

# Dropping missing values

df =df.dropna(subset=['Income'])

df['Income'].isna().sum()

# Descriptive statistics

df['Income'].describe()

# Check for duplicate values

df.duplicated()

# Count how many times each combination occurs

df[['ID','Kidhome','Teenhome'	]].value_counts()

df['Marital_Status'].value_counts()

# Removing suspicious values

# Step 1: Replace suspicious values with NULL

import numpy as np
df['Marital_Status'] = df['Marital_Status'].replace(['Alone', 'Absurd', 'YOLO'], np.nan)

df = df.dropna(subset=['Marital_Status'])

df['Marital_Status'].value_counts()

df.columns

# Renaming columns to informative names

df = df.rename(columns={
    'ID':'Customer_id',
    'MntWines':'Amount_wines',
    'MntFruits':'Amount_fruits',
    'MntMeatProducts':'Amount_meat_products',
    'MntFishProducts':'Amount_fish_products',
    'MntSweetProducts':'Amount_sweet_products',
    'MntGoldProds':'Amount_premium_products'
})

print(df.columns)

# Splitting the data into 5 tables

# Personal and demographic information

df_customers = df[['Customer_id', 'Year_Birth', 'Education', 'Marital_Status', 'Income',
       'Kidhome', 'Teenhome', 'Dt_Customer', 'Recency','Complain']]

# Purchase channels and buying behavior

df_purchase_channels = df[['Customer_id','NumWebPurchases', 'NumCatalogPurchases', 'NumStorePurchases',
       'NumWebVisitsMonth']]

# Purchase amounts by product category

df_spending = df[['Customer_id','Amount_wines',
       'Amount_fruits', 'Amount_meat_products', 'Amount_fish_products',
       'Amount_sweet_products', 'Amount_premium_products']]

type(df_spending)

# נתוני שווי כללי של הלקוח

df_customer_value = df[['Customer_id','Z_CostContact',
       'Z_Revenue']]

# General customer value information

df_campaign = df[['Customer_id','AcceptedCmp1', 'AcceptedCmp2','AcceptedCmp3', 'AcceptedCmp4', 'AcceptedCmp5','NumDealsPurchases','Response']]

# Saving to CSV files

df_customers.to_csv('customers.csv', index=False)
df_purchase_channels.to_csv('purchase_channels.csv', index=False)
df_spending.to_csv('spending.csv', index=False)
df_customer_value.to_csv('customer_value.csv', index=False)
df_campaign.to_csv('campaign.csv', index=False)