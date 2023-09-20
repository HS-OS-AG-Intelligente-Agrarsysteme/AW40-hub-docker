/*
 *  Copyright (c) 2021 Microsoft Corporation
 *
 *  This program and the accompanying materials are made available under the
 *  terms of the Apache License, Version 2.0 which is available at
 *  https://www.apache.org/licenses/LICENSE-2.0
 *
 *  SPDX-License-Identifier: Apache-2.0
 *
 *  Contributors:
 *       Microsoft Corporation - Initial implementation
 *       LMIS AG - Modifications made to the original code
 *
 */

package query;

import jakarta.json.JsonArray;
import jakarta.json.JsonObject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.edc.catalog.spi.QueryEngine;
import org.eclipse.edc.catalog.spi.QueryResponse;
import org.eclipse.edc.catalog.spi.model.FederatedCatalogCacheQuery;
import org.eclipse.edc.spi.result.AbstractResult;
import org.eclipse.edc.spi.result.Result;
import org.eclipse.edc.transform.spi.TypeTransformerRegistry;
import org.eclipse.edc.catalog.spi.FederatedCacheNode;
import org.eclipse.edc.catalog.spi.FederatedCacheNodeDirectory;
import java.util.List;

import static jakarta.json.stream.JsonCollectors.toJsonArray;

@Consumes({MediaType.APPLICATION_JSON})
@Produces({MediaType.APPLICATION_JSON})
@Path("/federatedcatalog")
public class FederatedCatalogApiController implements FederatedCatalogApi {

    private final QueryEngine queryEngine;
    private final TypeTransformerRegistry transformerRegistry;
    private final FederatedCacheNodeDirectory nodeDirectory;

    public FederatedCatalogApiController(QueryEngine queryEngine, TypeTransformerRegistry transformerRegistry, FederatedCacheNodeDirectory nodeDirectory) {
        this.queryEngine = queryEngine;
        this.transformerRegistry = transformerRegistry;
        this.nodeDirectory = nodeDirectory;
    }

    @Override
    @POST
    public JsonArray getCachedCatalog(FederatedCatalogCacheQuery federatedCatalogCacheQuery) {
        var queryResponse = queryEngine.getCatalog(federatedCatalogCacheQuery);
        // query not possible
        if (queryResponse.getStatus() == QueryResponse.Status.NO_ADAPTER_FOUND) {
            throw new QueryNotAcceptedException();
        }
        if (!queryResponse.getErrors().isEmpty()) {
            throw new QueryException(queryResponse.getErrors());
        }

        var catalogs = queryResponse.getCatalogs();
        return catalogs.stream().map(c -> transformerRegistry.transform(c, JsonObject.class))
                .filter(Result::succeeded)
                .map(AbstractResult::getContent)
                .collect(toJsonArray());
    }

    @POST
    @Path("/insert")
    public Response insertNode(FederatedCacheNode federatedCacheNode) {

        FederatedCacheNode newNode = new FederatedCacheNode(
            federatedCacheNode.getName(),
            federatedCacheNode.getTargetUrl(),
            federatedCacheNode.getSupportedProtocols()
        );

        nodeDirectory.insert(newNode);

        return Response.ok().build();
    }

    @GET
    @Path("/participants")
    @Produces(MediaType.APPLICATION_JSON)
    public List<FederatedCacheNode> getNodes() {

        return nodeDirectory.getAll();
    }

}
