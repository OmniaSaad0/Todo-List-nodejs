const mongoose = require('mongoose');
const date = new Date();
const currentTime = date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
const currentDate = date.getDate() + " " + getMonth(date.getMonth()) + " " + date.getFullYear();
console.log(currentDate);


function getMonth(monthNumber) {
    const monthsArr = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    return monthsArr[monthNumber];

}

const dashboardSchema = mongoose.Schema({
    task: {
        type: String,
        required: true
    },
    description: {
        type: String,
        required: false
    },
    currenttime: {
        type: String,
        default: currentTime
    },
    currentDate: { 
        type: String,
        default: currentDate
    },
    date: {
        type: String,
        required: true
    },
    time: {
        type: String,
        required: false
    },
    categoryChoosed: {
        type: String,
        required: true
    },
    completed: {
        type: Boolean,
        default: false
    }
});

const Dashboard = mongoose.model('Dashboard', dashboardSchema);
module.exports = Dashboard;
