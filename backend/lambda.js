import serverlessExpress from '@codegenie/serverless-express';
import app from './src/server.js';

export const handler = serverlessExpress({ app });
