# Simple-Budget
Just as it sounds, Simple Budget is a budgeting app. It starts on a login window, which allows users to create a new user
when the app is launched for the first time. Any username and password will work.

![image](https://cloud.githubusercontent.com/assets/11247733/11554180/a06808b0-994a-11e5-9c1f-4818c0a69ce9.png)

Upon login, the app displays a budgeting tab. Users can tap the "add item" buttons to add new budget subcategories.
The currency values are text fields that can be edited. A new transaction can manually be added by tapping the "+" 
to the right of the navigation bar.

![image](https://cloud.githubusercontent.com/assets/11247733/11554181/a1d814ce-994a-11e5-9080-fd1df067054c.png)

Here, the user can select the date the transaction occurred, the amount that was spent, the name of the merchant,
and any notes they may want to add. 

![image](https://cloud.githubusercontent.com/assets/11247733/11554183/a3645f78-994a-11e5-8e70-39989d6ce099.png)

By tapping the "choose budget category" row, a new view is displayed for choosing a category to file 
the transaction under. The category chooser displays all categories/subcategories that have already 
been saved, and their remaining budget amounts (the amount budgeted, minus the total of any transactions).

![image](https://cloud.githubusercontent.com/assets/11247733/11554184/a4f66f3e-994a-11e5-83e9-71b25eeb4cff.png)

After the transaction is saved, the user is returned to the budget view, and the "spent" and "remaining" tabs can be viewed.
The spent tab shows the total of the transactions in each subcategory.

![image](https://cloud.githubusercontent.com/assets/11247733/11554186/a6421d3e-994a-11e5-958e-5094492f8203.png)

Like the category chooser, the remaining tab shows the budget amount for each subcategory, minus the total of any transactions.

![image] (https://cloud.githubusercontent.com/assets/11247733/11554187/a7970384-994a-11e5-8e82-50a554b3398e.png)

Finally, the user can link their own bank account by tapping "connect" to the left of the navigation bar. This will present
a view for the user to select their banking institution, and enter their banking login credentials. Not all banks have been
tested at this time. For test purposes, the username 'plaid_test' and password 'plaid_good' can be used.

![image](https://cloud.githubusercontent.com/assets/11247733/11554188/a8cd01fe-994a-11e5-9c92-abcd32f13c16.png)

By tapping "save", the app utilizes the Plaid API to connect to the user's bank and download transactions from the past
30 days. The user is then returned to the budgeting view. Downloaded and manually saved transactions can be viewed by
tapping on the desired subcategory. They are displayed in a new view, in a table, with the date the transaction was 
completed, the merchant or description, and the total. If using the test login credentials, downloaded transactions can be found under the "Other" and "Transfer" categories.

![image](https://cloud.githubusercontent.com/assets/11247733/11554189/aa243cac-994a-11e5-91b5-492bd336d77d.png)

