// lambda.js - AWS Lambda handler for serverless express
const serverlessExpress = require('@vendia/serverless-express');
const app = require('./infrastructure/web/routes/mainRoutes');

// Create the serverless express handler
exports.handler = serverlessExpress({ app });