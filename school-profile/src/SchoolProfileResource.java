package fr.atelier.comptes;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.net.URI;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.Set;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.HeaderParam;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.Provider;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.UserModel;
import org.keycloak.services.managers.AppAuthManager;
import org.keycloak.services.managers.AuthenticationManager;

@Provider
@Produces(MediaType.APPLICATION_JSON)
public final class SchoolProfileResource {
    private static final String ATTRIBUTE = "atelierSchoolProfile";
    private static final ZoneId PARIS = ZoneId.of("Europe/Paris");
    private static final List<String> GRADES =
        List.of("CP", "CE1", "CE2", "CM1", "CM2", "6e", "5e", "4e", "3e");
    private static final Set<String> APPLICATIONS = Set.of(
        "dictees-personnalisees", "fractions-visuelles", "apprendre-heure",
        "vocabulaire-anglais", "chronologie-historique");

    private final KeycloakSession session;

    SchoolProfileResource(KeycloakSession session) {
        this.session = session;
    }

    public record Update(@JsonProperty(value = "grade", required = true) String grade, String revision) {}
    public record Profile(String grade, String revision, String schoolYear, boolean confirmationDue, String suggestedGrade) {}

    @GET
    public Response applicationProfile() {
        return response(200, profile(applicationUser()));
    }

    @PUT
    @Consumes(MediaType.APPLICATION_JSON)
    public Response updateApplicationProfile(Update update) {
        return save(applicationUser(), update);
    }

    @GET
    @Path("compte")
    public Response accountProfile() {
        return response(200, profile(accountUser()));
    }

    @PUT
    @Path("compte")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response updateAccountProfile(@HeaderParam("Origin") String origin, Update update) {
        URI base = session.getContext().getUri().getBaseUri();
        if (!(base.getScheme() + "://" + base.getAuthority()).equals(origin)) {
            throw error(403);
        }
        return save(accountUser(), update);
    }

    private UserModel applicationUser() {
        checkRealm();
        var auth = new AppAuthManager.BearerTokenAuthenticator(session).authenticate();
        if (auth == null || auth.session() == null || !"Bearer".equals(auth.token().getType())) {
            throw error(401);
        }
        if (!APPLICATIONS.contains(auth.token().getIssuedFor())) {
            throw error(403);
        }
        return auth.user();
    }

    private UserModel accountUser() {
        checkRealm();
        var auth = AuthenticationManager.authenticateIdentityCookie(session, session.getContext().getRealm(), true);
        if (auth == null) throw error(401);
        return auth.user();
    }

    private void checkRealm() {
        if (!"comptes".equals(session.getContext().getRealm().getName())) throw error(404);
    }

    private static int schoolYear() {
        LocalDate today = LocalDate.now(PARIS);
        return today.getMonthValue() >= 9 ? today.getYear() : today.getYear() - 1;
    }

    private static Profile profile(UserModel user) {
        int currentYear = schoolYear();
        String label = currentYear + "–" + (currentYear + 1);
        String value = user.getFirstAttribute(ATTRIBUTE);
        if (value != null) {
            String[] parts = value.split(":", -1);
            if (parts.length == 2 && GRADES.contains(parts[0]) && parts[1].matches("\\d{4}")) {
                int year = Integer.parseInt(parts[1]);
                int index = GRADES.indexOf(parts[0]);
                boolean due = year < currentYear;
                String next = due && index + 1 < GRADES.size() ? GRADES.get(index + 1) : null;
                return new Profile(parts[0], value, label, due, next);
            }
        }
        return new Profile(null, "", label, false, null);
    }

    private static Response save(UserModel user, Update update) {
        if (update == null || update.revision() == null ||
                (update.grade() != null && !GRADES.contains(update.grade()))) {
            throw error(400);
        }
        var existing = profile(user);
        if (!existing.revision().equals(update.revision())) {
            if (!existing.confirmationDue() && java.util.Objects.equals(existing.grade(), update.grade())) {
                return response(200, existing);
            }
            return response(409, existing);
        }
        if (update.grade() == null) {
            user.removeAttribute(ATTRIBUTE);
        } else {
            user.setSingleAttribute(ATTRIBUTE, update.grade() + ":" + schoolYear());
        }
        return response(200, profile(user));
    }

    private static Response response(int status, Profile entity) {
        return Response.status(status).header("Cache-Control", "no-store").entity(entity).build();
    }

    private static WebApplicationException error(int status) {
        return new WebApplicationException(Response.status(status).header("Cache-Control", "no-store").build());
    }
}
