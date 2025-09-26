-- Create database user                                                         
CREATE USER django_proj*user WITH PASSWORD 'django_pw*';                        
                                                                                
-- Set default role parameters                                                  
ALTER ROLE django_proj*user SET client_encoding TO 'utf8';                      
ALTER ROLE django_proj*user SET default_transaction_isolation TO 'read committed';
ALTER ROLE django_proj*user SET timezone TO 'time_zone*';                       
                                                                                
-- Create database owned by the Django user                                     
CREATE DATABASE django_proj*db OWNER django_proj*user;                            
                                                                                  
-- Ensure schema ownership and privileges                                         
ALTER SCHEMA public OWNER TO django_proj*user;                                    
GRANT ALL PRIVILEGES ON DATABASE django_proj*db TO django_proj*user;            
GRANT ALL ON SCHEMA public TO django_proj*user;                                 
GRANT CREATE ON SCHEMA public TO django_proj*user;                                
GRANT USAGE ON SCHEMA public TO django_proj*user;
