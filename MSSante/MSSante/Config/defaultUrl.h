//
//  defaultUrl.h
//  MSSante
//
//  Created by Labinnovation on 10/04/2015.
//  Copyright (c) 2015 Capgemini. All rights reserved.
//

#ifndef MSSante_defaultUrl_h
#define MSSante_defaultUrl_h

#if defined(DEV)
#define DEFAULT_ENV @"dev"

#elif defined(QUALIF)
#define DEFAULT_ENV @"qualification"

#elif defined(FORMATION)
#define DEFAULT_ENV @"formation"

#elif defined(PREPROD)
#define DEFAULT_ENV @"isoproduction"

#elif defined(PROD)
#define DEFAULT_ENV @"production"

#else
#define DEFAULT_ENV @"production"
#endif


//No Logs
#define DLog(...)
#define ConnectionLog(...)

//kProd Capgemini => distrib
//kProd ASIP => prod2
#define kProd @"distrib"

#endif