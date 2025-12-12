import 'dotenv/config';
import oracledb from 'oracledb';
import dotenv from 'dotenv';


export function getDbConfig() {
    return {
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        connectString: process.env.DB_CONNECT_STRING,
    };
}

export async function getConnection() {
    const config = getDbConfig();
    
    if (!config.user || !config.password || !config.connectString) {
        throw new Error('Database credentials not set in .env file');
    }
    
    const connection = await oracledb.getConnection(config);
    if (!connection) {
        throw new Error('Failed to establish database connection');
    }
    await connection.commit();
    return connection;
}